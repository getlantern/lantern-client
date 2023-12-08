import 'package:lantern/account/account_tab.dart';
import 'package:lantern/account/developer_settings.dart';
import 'package:lantern/account/privacy_disclosure.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/messaging/chats.dart';
import 'package:lantern/messaging/onboarding/welcome.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/replica/replica_tab.dart';
import 'package:lantern/vpn/try_lantern_chat.dart';
import 'package:lantern/vpn/vpn_tab.dart';
import 'package:logger/logger.dart';

import 'messaging/messaging_model.dart';

@RoutePage(name: 'Home')
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BuildContext? _context;
  MethodChannel? mainMethodChannel;
  MethodChannel? navigationChannel;

  Function()? _cancelEventSubscription;

  _HomePageState();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      mainMethodChannel = const MethodChannel('lantern_method_channel');
      navigationChannel = const MethodChannel('navigation');
      sessionModel.getChatEnabled().then((chatEnabled) {
        if (chatEnabled) {
          messagingModel
              .shouldShowTryLanternChatModal()
              .then((shouldShowModal) async {
            if (shouldShowModal) {
              // open VPN tab
              await sessionModel.setSelectedTab(TAB_VPN);
              // show Try Lantern Chat dialog
              await context.router
                  .push(FullScreenDialogPage(widget: TryLanternChat()));
            }
          });
        }
      });

      navigationChannel?.setMethodCallHandler(_handleNativeNavigationRequest);
      // Let back-end know that we're ready to handle navigation
      navigationChannel?.invokeListMethod('ready');
      _cancelEventSubscription =
          sessionModel.eventManager.subscribe(Event.All, (event, params) {
            switch (event) {
              case Event.SurveyAvailable:
                final message = params['message'] as String;
                final buttonText = params['buttonText'] as String;
                final snackBar = SnackBar(
                  backgroundColor: Colors.black,
                  duration: const Duration(days: 99999),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  behavior: SnackBarBehavior.floating,
                  margin:
                  const EdgeInsetsDirectional.only(
                      start: 8, end: 8, bottom: 16),
                  // simple way to show indefinitely
                  content: CText(
                    message,
                    style: CTextStyle(
                      fontSize: 14,
                      lineHeight: 21,
                      color: white,
                    ),
                  ),
                  action: SnackBarAction(
                    textColor: pink3,
                    label: buttonText.toUpperCase(),
                    onPressed: () {
                      mainMethodChannel?.invokeMethod('showLastSurvey');
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                break;
              default:
                break;
            }
          });
    }
    }

  Future<dynamic> _handleNativeNavigationRequest(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'openConversation':
        final contact = Contact.fromBuffer(methodCall.arguments as Uint8List);
        await _context!.router.push(Conversation(contactId: contact.contactId));
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

  Widget build(BuildContext context) {
    _context = context;
    return sessionModel.acceptedTermsVersion(
      (BuildContext context, int version, Widget? child) {
        return sessionModel.developmentMode(
          (BuildContext context, bool developmentMode, Widget? child) {
            if (developmentMode) {
              Logger.level = Level.verbose;
            } else {
              Logger.level = Level.error;
            }

            bool isPlayVersion = (sessionModel.isPlayVersion.value??false);
            bool isStoreVersion = (sessionModel.isStoreVersion.value??false);

            if ((isPlayVersion||isStoreVersion) && version == 0) {
              // show privacy disclosure if it's a Play build and the terms have
              // not already been accepted
              return const PrivacyDisclosure();
            }
            return sessionModel.selectedTab(
                  (context, selectedTab, child) => messagingModel
                  .getOnBoardingStatus((_, isOnboarded, child) {
                final isTesting = const String.fromEnvironment(
                  'driver',
                  defaultValue: 'false',
                ).toLowerCase() ==
                    'true';
                final tab = Platform.isAndroid ? selectedTab : ffiSelectedTab().toDartString();
                return Scaffold(
                  body: buildBody(tab, isOnboarded),
                  bottomNavigationBar: CustomBottomBar(
                    selectedTab: tab,
                    isDevelop: developmentMode,
                    isTesting: isTesting,
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }

  @override
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
