import 'dart:ui' as ui;

import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/account/account_tab.dart';
import 'package:lantern/features/account/developer_settings.dart';
import 'package:lantern/features/account/privacy_disclosure.dart';
import 'package:lantern/features/messaging/chats.dart';
import 'package:lantern/features/messaging/onboarding/welcome.dart';
import 'package:lantern/features/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/features/replica/replica_tab.dart';
import 'package:lantern/features/vpn/try_lantern_chat.dart';
import 'package:lantern/features/vpn/vpn.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:lantern/features/vpn/vpn_tab.dart';
import 'package:logger/logger.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../messaging/messaging_model.dart';

@RoutePage(name: 'Home')
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener, WindowListener {
  Function()? _cancelEventSubscription;
  Function userNew = once<void>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _startupSequence();
    });
  }

  void _startupSequence() {
    if (isMobile()) {
      channelListener();
      return;
    }
    // This is a desktop device
    _setupTrayManager();
    _initWindowManager();
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

  ///window manager methods
  void _initWindowManager() async {
    windowManager.addListener(this);
    if (Theme.of(context).platform != TargetPlatform.windows) return;
    // temporary workaround for distorted layout on Windows. The problem goes
    // away after the window is resized.
    // See https://github.com/leanflutter/window_manager/issues/464
    await Future<void>.delayed(const Duration(milliseconds: 100), () {
      windowManager.getSize().then((ui.Size value) {
        windowManager.setSize(
          ui.Size(value.width + 1, value.height + 1),
        );
      });
    });
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
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  /// system tray methods
  void _setupTrayManager() async {
    trayManager.addListener(this);
    final vpnNotifier = context.read<VPNChangeNotifier>();
    await _updateTrayMenu();
    vpnNotifier.vpnStatus.addListener(_updateTrayMenu);
  }

  /// this method updates the tray menu based on the current VPN status
  Future<void> _updateTrayMenu() async {
    final vpnNotifier = context.read<VPNChangeNotifier>();
    final isConnected = vpnNotifier.isConnected();
    await trayManager.setIcon(getSystemTrayIconPath(isConnected));
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
          onClick: (item) => vpnNotifier.toggleConnection(),
        ),
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
          onClick: (item) async {
            LanternFFI.exit();
            await trayManager.destroy();
            await windowManager.destroy();
            exit(0);
          },
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
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
