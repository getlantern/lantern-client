import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/event/Event.dart';
import 'package:lantern/event/EventManager.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_toast/custom_toast.dart';
import 'package:lantern/ui/widgets/new_bottom_nav.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  BuildContext? _context;
  final mainMethodChannel = const MethodChannel('lantern_method_channel');
  final navigationChannel = const MethodChannel('navigation');

  Function()? _cancelEventSubscription;

  _HomePageState();

  @override
  void initState() {
    super.initState();
    final eventManager = EventManager('lantern_event_channel');
    navigationChannel.setMethodCallHandler(_handleNativeMethodCall);
    _cancelEventSubscription =
        eventManager.subscribe(Event.All, (eventName, params) {
      final event = EventParsing.fromValue(eventName);
      switch (event) {
        case Event.SurveyAvailable:
          final message = params['message'] as String;
          final buttonText = params['buttonText'] as String;
          CustomToast.show(
            title: 'Lantern',
            surveyText: buttonText,
            onSurvey: () async =>
                await mainMethodChannel.invokeMethod('showLastSurvey'),
            body: message,
            icon: const Icon(Icons.notifications_active),
            duration: const Duration(days: 99999),
          );
          break;
        default:
          throw Exception('Unhandled event $event');
      }
    });
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall methodCall) async {
    if (methodCall.method == 'openConversation') {
      await _context!
          .innerRouterOf<TabsRouter>(Home.name)!
          .innerRouterOf<StackRouter>(MessagesRouter.name)!
          .push(Conversation(
              contact: Contact.fromBuffer(methodCall.arguments as Uint8List)));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_cancelEventSubscription != null) {
      _cancelEventSubscription!();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    var sessionModel = context.watch<SessionModel>();
    return sessionModel.developmentMode(
      (BuildContext context, bool developmentMode, Widget? child) {
        return sessionModel.language(
          (BuildContext context, String lang, Widget? child) {
            Localization.locale = lang;
            return AutoTabsScaffold(
              routes: [
                const MessagesRouter(),
                Vpn(),
                const Account(),
                if (developmentMode) Developer(),
              ],
              bottomNavigationBuilder: (context, tabsRouter) =>
                  buildBottomNav(context, tabsRouter, developmentMode),
            );
          },
        );
      },
    );
  }

  Widget buildBottomNav(
          BuildContext context, TabsRouter tabsRouter, bool isDevelop) =>
      NewBottomNav(
        onTap: tabsRouter.setActiveIndex,
        index: tabsRouter.activeIndex,
        isDevelop: isDevelop,
      );
}
