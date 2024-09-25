import 'package:lantern/account/account_tab.dart';
import 'package:lantern/account/developer_settings.dart';
import 'package:lantern/account/privacy_disclosure.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/ffi.dart';
import 'package:lantern/messaging/chats.dart';
import 'package:lantern/messaging/onboarding/welcome.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/replica/replica_tab.dart';
import 'package:lantern/vpn/try_lantern_chat.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/vpn/vpn_notifier.dart';
import 'package:lantern/vpn/vpn_tab.dart';
import 'package:logger/logger.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'messaging/messaging_model.dart';

@RoutePage(name: 'Home')
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener, WindowListener {
  Function()? _cancelEventSubscription;
  Function userNew = once<void>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _startupSequence();
    });
    super.initState();
  }

  void _startupSequence() {
    if (isMobile()) {
      // This is a mobile device
      channelListener();
    } else {
      // This is a desktop device
      _setupTrayManager();
      _initWindowManager();
    }
  }

  void _setupTrayManager() async {
    trayManager.addListener(this);
    _setupTray();
  }

  void _initWindowManager() async {
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  Future<void> _updateTrayMenu() async {
    final isConnected =
        context.read<VPNChangeNotifier>().vpnStatus.value == 'connected';
    await trayManager.setIcon(systemTrayIcon(isConnected));
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'status',
          disabled: true,
          label: isConnected ? 'status_on'.i18n : 'status_off'.i18n,
        ),
        MenuItem(
            key: 'status',
            label: isConnected ? 'disconnect'.i18n : 'connect'.i18n,
            onClick: (item) {
              context.read<VPNChangeNotifier>().toggleConnection();
            }),
        MenuItem.separator(),
        MenuItem(
            key: 'show_window',
            label: 'show'.i18n,
            onClick: (item) {
              windowManager.focus();
              windowManager.setSkipTaskbar(false);
            }),
        MenuItem.separator(),
        MenuItem(
            key: 'exit',
            label: 'exit'.i18n,
            onClick: (item) {
              windowManager.destroy();
              LanternFFI.exit();
            }),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  void _setupTray() async {
    final vpnNotifier = context.read<VPNChangeNotifier>();
    await _updateTrayMenu();
    vpnNotifier.vpnStatus.addListener(_updateTrayMenu);
  }

  @override
  Future<void> onTrayIconMouseDown() async {
    windowManager.show();
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (!isPreventClose) return;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('confirm_close_window'.i18n),
          actions: [
            TextButton(
              child: Text('No'.i18n),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'.i18n),
              onPressed: () async {
                LanternFFI.exit();
                await trayManager.destroy();
                await windowManager.destroy();
              },
            ),
          ],
        );
      },
    );
  }

  void channelListener() {
    if (Platform.isIOS) return;

    const mainMethodChannel = MethodChannel('lantern_method_channel');
    const navigationChannel = MethodChannel('navigation');
    if (Platform.isAndroid) {
      sessionModel.getChatEnabled().then((chatEnabled) {
        if (chatEnabled) {
          messagingModel
              .shouldShowTryLanternChatModal()
              .then((shouldShowModal) async {
            if (shouldShowModal) {
              // open VPN tab
              sessionModel.setSelectedTab(context, TAB_VPN);
              // show Try Lantern Chat dialog
              await context.router
                  .push(FullScreenDialogPage(widget: TryLanternChat()));
            }
          });
        }
      });
    }

    navigationChannel.setMethodCallHandler(_handleNativeNavigationRequest);
    // Let back-end know that we're ready to handle navigation
    navigationChannel.invokeListMethod('ready');
    _cancelEventSubscription =
        sessionModel.eventManager.subscribe(Event.All, (event, params) {
      switch (event) {
        case Event.SurveyAvailable:
          // show survey snackbar
          showSuerySnackbar(
              context: context,
              buttonText: params['buttonText'] as String,
              message: params['message'] as String,
              onPressed: () {
                mainMethodChannel.invokeMethod('showLastSurvey');
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              });

          break;
        default:
          break;
      }
    });
  }

  Future<void> _checkForFirstTimeVisit() async {
    checkForFirstTimeVisit() async {
      if (sessionModel.proUserNotifier.value == null) {
        return;
      }
      if (sessionModel.proUserNotifier.value!) {
        sessionModel.setFirstTimeVisit();
        if (sessionModel.proUserNotifier.hasListeners) {
          sessionModel.proUserNotifier.removeListener(() {});
        }
        return;
      }
      final isFirstTime = await sessionModel.isUserFirstTimeVisit();
      if (isFirstTime) {
        context.router.push(const AuthLanding());
        sessionModel.setFirstTimeVisit();
        if (sessionModel.proUserNotifier.hasListeners) {
          sessionModel.proUserNotifier.removeListener(() {});
        }
      }
    }

    if (sessionModel.proUserNotifier.value != null) {
      checkForFirstTimeVisit();
    } else {
      sessionModel.proUserNotifier.addListener(() async {
        checkForFirstTimeVisit();
      });
    }
  }

  Future<dynamic> _handleNativeNavigationRequest(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'openConversation':
        final contact = Contact.fromBuffer(methodCall.arguments as Uint8List);
        await context.router.push(Conversation(contactId: contact.contactId));
        break;
      default:
        return;
    }
  }

  @override
  void dispose() {
    if (isDesktop()) {
      trayManager.removeListener(this);
      windowManager.removeListener(this);
    }
    if (_cancelEventSubscription != null) {
      _cancelEventSubscription!();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabModel = context.watch<BottomBarChangeNotifier>();
    return sessionModel.acceptedTermsVersion(
      (BuildContext context, int version, Widget? child) {
        return sessionModel.developmentMode(
          (BuildContext context, bool developmentMode, Widget? child) {
            if (developmentMode) {
              Logger.level = Level.trace;
            } else {
              Logger.level = Level.error;
            }

            bool isPlayVersion =
                (sessionModel.isTestPlayVersion.value ?? false);
            bool isStoreVersion = (sessionModel.isStoreVersion.value ?? false);

            if ((isStoreVersion || isPlayVersion) && version == 0) {
              // show privacy disclosure if it's a Play build and the terms have
              // not already been accepted
              return const PrivacyDisclosure();
            }

            if (sessionModel.isAuthEnabled.value!) {
              userNew(() {
                _checkForFirstTimeVisit();
              });
            }

            return messagingModel.getOnBoardingStatus((_, isOnboarded, child) {
              final tab = tabModel.currentIndex;
              return Scaffold(
                body: buildBody(tab, isOnboarded),
                bottomNavigationBar: CustomBottomBar(
                  selectedTab: tab,
                  isDevelop: developmentMode,
                ),
              );
            });
          },
        );
      },
    );
  }

  Widget buildBody(String selectedTab, bool? isOnboarded) {
    switch (selectedTab) {
      case TAB_CHATS:
        return isOnboarded == null
            // While onboarding status is not yet know, show a white container
            // that matches the background of our usual pages.
            ? Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(color: white),
              )
            : isOnboarded
                ? Chats()
                : Welcome();
      case TAB_VPN:
        return const VPNTab();
      case TAB_REPLICA:
        return ReplicaTab();
      case TAB_ACCOUNT:
        return AccountTab();
      case TAB_DEVELOPER:
        return DeveloperSettingsTab();
      default:
        assert(false, 'unrecognized tab $selectedTab');
        return Container();
    }
  }
}
