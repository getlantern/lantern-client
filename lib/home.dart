import 'package:lantern/account/account_tab.dart';
import 'package:lantern/account/developer_settings.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/messaging/chats.dart';
import 'package:lantern/messaging/onboarding/welcome.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/replica/ui/replica_tab.dart';
import 'package:lantern/vpn/try_lantern_chat.dart';
import 'package:lantern/vpn/vpn_tab.dart';
import 'package:logger/logger.dart';

import 'messaging/messaging_model.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BuildContext? _context;
  final mainMethodChannel = const MethodChannel('lantern_method_channel');
  final navigationChannel = const MethodChannel('navigation');

  Function()? _cancelEventSubscription;

  _HomePageState();

  @override
  void initState() {
    super.initState();

    // Figure out where to start with our navigation
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

    // Cache plans and user status in session storage
    sessionModel.updateAndCachePlans();
    sessionModel.updateAndCacheUserStatus();

    navigationChannel.setMethodCallHandler(_handleNativeNavigationRequest);

    // Let back-end know that we're ready to handle navigation
    navigationChannel.invokeListMethod('ready');

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
                const EdgeInsetsDirectional.only(start: 8, end: 8, bottom: 16),
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
                mainMethodChannel.invokeMethod('showLastSurvey');
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          break;
        case Event.All:
        case Event.NoNetworkAvailable:
        case Event.NetworkAvailable:
        case Event.NoProxyAvailable:
        case Event.ProxyAvailable:
          break;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    _context = context;
    return sessionModel.developmentMode(
      (BuildContext context, bool developmentMode, Widget? child) {
        if (developmentMode) {
          Logger.level = Level.verbose;
        } else {
          Logger.level = Level.error;
        }
        return sessionModel.language(
          (BuildContext context, String lang, Widget? child) {
            Localization.locale = lang;
            return sessionModel.selectedTab(
              (context, selectedTab, child) =>
                  messagingModel.getOnBoardingStatus((_, isOnboarded, child) {
                final isTesting = const String.fromEnvironment(
                      'driver',
                      defaultValue: 'false',
                    ).toLowerCase() ==
                    'true';
                return sessionModel.getCachedPlans(
                  (context, cachedPlans, child) => sessionModel.getUserStatus(
                    (context, userStatus, child) => Scaffold(
                      body: buildBody(
                        selectedTab,
                        isOnboarded,
                        cachedPlans,
                        userStatus,
                      ),
                      bottomNavigationBar: CustomBottomBar(
                        selectedTab: selectedTab,
                        isDevelop: developmentMode,
                        isTesting: isTesting,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }

  Widget buildBody(
    String selectedTab,
    bool? isOnboarded,
    String? cachedPlans,
    String? userStatus,
  ) {
    final isCN = determineLocation(cachedPlans);
    final isPlatinum = determinePlatinum(userStatus);
    switch (selectedTab) {
      case TAB_CHATS:
        sessionModel.trackScreenView('Chats');
        return isOnboarded == null
            // While onboarding status is not yet know, show a white container
            // that matches the background of our usual pages.
            ? Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(color: white),
              )
            : isOnboarded
                ? Chats(
                    isCN: isCN,
                    isPlatinum: isPlatinum,
                  )
                : Welcome();
      case TAB_VPN:
        sessionModel.trackScreenView('VPN');
        return VPNTab(
          isCN: isCN,
          isPlatinum: isPlatinum,
        );
      case TAB_REPLICA:
        sessionModel.trackScreenView('Replica');
        return ReplicaTab();
      case TAB_ACCOUNT:
        sessionModel.trackScreenView('Account');
        return AccountTab(
          isCN: isCN,
          isPlatinum: isPlatinum,
        );
      case TAB_DEVELOPER:
        sessionModel.trackScreenView('Developer');
        return DeveloperSettingsTab();
      default:
        assert(false, 'unrecognized tab $selectedTab');
        return Container();
    }
  }

  // returns true if there are any Plans entries where { level: 'platinum' }
  // depends on where the plans are fetched from
  bool determineLocation(String? cachedPlans) {
    if (cachedPlans == null) return false;
    final cachedPlansMap = jsonDecode(cachedPlans) as Map;
    final anyPlatinumLevels = cachedPlansMap.entries.map((p) {
      final availablePlan = p.value as Map;
      return availablePlan['level'] == 'platinum';
    });
    return anyPlatinumLevels.contains(true);
  }

  // returns true if the user status is platinum
  // is independent of where the plans are fetched from
  bool determinePlatinum(String? userStatus) {
    return userStatus != null && userStatus == 'platinum';
  }
}
