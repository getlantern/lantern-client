import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/core/router/router_extensions.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/event_extension.dart';
import 'package:lantern/event_manager.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

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
    final eventManager = EventManager('lantern_event_channel');
    navigationChannel.setMethodCallHandler(_handleNativeNavigationRequest);
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
        await _context!.openConversation(contact.contactId);
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
    var sessionModel = context.watch<SessionModel>();
    var messagingModel = context.watch<MessagingModel>();
    return sessionModel.developmentMode(
      (BuildContext context, bool developmentMode, Widget? child) {
        return sessionModel.language(
          (BuildContext context, String lang, Widget? child) {
            Localization.locale = lang;
            return messagingModel.getOnBoardingStatus(
                (context, isOnboarded, child) => AutoTabsScaffold(
                      routes: [
                        isOnboarded
                            ? const MessagesRouter()
                            : const OnboardingRouter(),
                        const VpnRouter(),
                        const AccountRouter(),
                        if (developmentMode) const DeveloperRoute(),
                      ],
                      bottomNavigationBuilder: (context, tabsRouter) =>
                          CustomBottomBar(
                        onTap: tabsRouter.setActiveIndex,
                        index: tabsRouter.activeIndex,
                        isDevelop: developmentMode,
                      ),
                    ));
          },
        );
      },
    );
  }
}
