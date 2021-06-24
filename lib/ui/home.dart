import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/event/Event.dart';
import 'package:lantern/event/EventManager.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/model/tab_status.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/routes.dart';
import 'package:lantern/ui/widgets/account/developer_settings.dart';
import 'package:lantern/ui/widgets/new_bottom_nav.dart';

import 'widgets/vpn/vpn.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentIndex = 0;
  final mainMethodChannel = const MethodChannel('lantern_method_channel');

  Function()? _cancelEventSubscription;

  _HomePageState();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    final eventManager = EventManager('lantern_event_channel');

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
            content: Text(message),
            action: SnackBarAction(
              textColor: secondaryPink,
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
    _handleNavigationRequestsFromNative();
  }

  void _handleNavigationRequestsFromNative() {
    var navigationChannel = const MethodChannel('navigation');
    navigationChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'openConversation':
          Navigator.pushNamed(context, '/messaging/conversation',
              arguments: Contact.fromBuffer(call.arguments as Uint8List));
          break;
        default:
          throw Exception('unknown navigation method ${call.method}');
      }
      return Future.value(null);
    });
    // navigationChannel.invokeMethod('ready');
  }

  void onPageChange(int index) => setState(() => _currentIndex = index);

  @override
  void dispose() {
    _pageController.dispose();
    if (_cancelEventSubscription != null) {
      _cancelEventSubscription!();
    }
    super.dispose();
  }

  void onUpdateCurrentIndexPageView(int index) =>
      _pageController.jumpToPage(index);

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();
    return sessionModel.developmentMode(
      (BuildContext context, bool developmentMode, Widget? child) {
        return sessionModel.language(
          (BuildContext context, String lang, Widget? child) {
            Localization.locale = lang;
            return AutoTabsScaffold(
              routes: [
                const Messages(),
                Vpn(),
                const Account(),
                if (developmentMode) Developer(),
              ],
              // body: PageView(
              //   onPageChanged: onPageChange,
              //   controller: _pageController,
              //   physics: const NeverScrollableScrollPhysics(),
              //   children: [
              //     TabStatusProvider(
              //       pageController: _pageController,
              //       index: 0,
              //       child: MessagesTab(
              //           _initialRoute.replaceFirst(routeMessaging, ''),
              //           widget._initialRouteArguments),
              //     ),
              //     VPNTab(),
              //     AccountTab(),
              //     if (developmentMode) DeveloperSettingsTab(),
              //   ],
              // ),
              bottomNavigationBuilder: (context, tabsRouter) =>
                  buildBottomNav(context, tabsRouter, developmentMode),
            );
          },
        );
      },
    );
  }

  Widget buildBottomNav(
      BuildContext context, TabsRouter tabsRouter, bool isDevelop) {
    return NewBottomNav(
      onTap: tabsRouter.setActiveIndex,
      index: tabsRouter.activeIndex,
      isDevelop: isDevelop,
    );
  }
}
