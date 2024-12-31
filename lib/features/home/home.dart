import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/utils.dart';
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
import 'package:lantern/features/vpn/vpn_tab.dart';
import 'package:logger/logger.dart';

import '../messaging/messaging_model.dart';

@RoutePage(name: 'Home')
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      print('isFirstTimeVisit: $isFirstTime');
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
            if (((isStoreVersion || isPlayVersion) && version == 0) && !byPassPrivacyPolicy()) {
              // show privacy disclosure if it's a  build and the terms have
              // not already been accepted
              return const PrivacyDisclosure();
            }

            if (sessionModel.isAuthEnabled.value! && !byPassAuth()) {
              userNew(() {
                _checkForFirstTimeVisit();
              });
            }
          print('isPlayVersion: $isPlayVersion');
            return messagingModel.getOnBoardingStatus((_, isOnboarded, child) {
              final tab = tabModel.currentIndex;
              print("tab: $tab");
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
