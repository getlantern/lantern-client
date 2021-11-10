import 'package:lantern/account/account_tab.dart';
import 'package:lantern/account/developer_settings.dart';
import 'dart:typed_data';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/core/router/router_helpers.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/messaging/chats.dart';
import 'package:lantern/messaging/onboarding/welcome.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/vpn/try_lantern_chat.dart';
import 'package:lantern/vpn/vpn_tab.dart';
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
    messagingModel
        .shouldShowTryLanternChatModal()
        .then((shouldShowModal) async {
      if (shouldShowModal) {
        // open VPN tab
        await sessionModel.setTabIndex(lookupTabIndex('VPN'));
        // show Try Lantern Chat dialog
        await context.router
            .push(FullScreenDialogPage(widget: TryLanternChat()));
      }
    });

    final eventManager = EventManager('lantern_event_channel');
    navigationChannel.setMethodCallHandler(_handleNativeNavigationRequest);
    // Let back-end know that we're ready to handle navigation
    navigationChannel.invokeListMethod('ready');
    _cancelEventSubscription =
        eventManager.subscribe(Event.All, (eventName, params) {
      final event = EventParsing.fromValue(eventName);
      switch (event) {
        case Event.SurveyAvailable:
          final message = params['message'] as String;
          final buttonText = params['buttonText'] as String;
          final snackBar = SnackBar(
            backgroundColor: Colors.black,
            duration: const Duration(days: 99999),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            behavior: SnackBarBehavior.floating,
            margin:
                const EdgeInsetsDirectional.only(start: 8, end: 8, bottom: 16),
            // simple way to show indefinitely
            content:
                CText(message, style: CTextStyle(fontSize: 14, lineHeight: 21)),
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
        default:
          throw Exception('Unhandled event $event');
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
        return sessionModel.language(
          (BuildContext context, String lang, Widget? child) {
            Localization.locale = lang;
            return sessionModel.tabIndex(
              (context, tabIndex, child) =>
                  messagingModel.getOnBoardingStatus((_, isOnboarded, child) {
                return Scaffold(
                  body: buildBody(tabIndex, isOnboarded),
                  bottomNavigationBar: CustomBottomBar(
                    onTap: (val) async {
                      await sessionModel.setTabIndex(val);
                    },
                    index: tabIndex,
                    isDevelop: developmentMode,
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }

  Widget buildBody(int tabIndex, bool? isOnboarded) {
    switch (tabIndex) {
      case 0:
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
      case 1:
        return VPNTab();
      case 2:
        return AccountTab();
      case 3:
        return DeveloperSettingsTab();
      default:
        assert(false, 'unrecognized tab index $tabIndex');
        return Container();
    }
  }
}
