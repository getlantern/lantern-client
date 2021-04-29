import 'package:flutter/material.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/routes.dart';
import 'package:lantern/utils/hex_color.dart';

import 'widgets/vpn/vpn.dart';

class HomePage extends StatefulWidget {
  final String _initialRoute;
  final dynamic _initialRouteArguments;

  HomePage(this._initialRoute, this._initialRouteArguments, {Key? key})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(_initialRoute);
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentIndex = 0;
  final String _initialRoute;

  late Future<void> loadAsync;

  _HomePageState(this._initialRoute) {
    if (_initialRoute.startsWith(routeVPN)) {
      _currentIndex = 1;
    } else if (_initialRoute.startsWith(routeSettings)) {
      _currentIndex = 2;
    } else if (_initialRoute.startsWith(routeAccount)) {
      _currentIndex = 3;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    final mainMethodChannel = const MethodChannel('lantern_method_channel');
    final eventManager = EventManager('lantern_event_channel');
    loadAsync = Localization.loadTranslations();

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
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
            // simple way to show indefinitely
            content: Text(message),
            action: SnackBarAction(
              textColor: HexColor(secondaryPink),
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
        default:
          throw Exception('unknown navigation method ${call.method}');
      }
      return Future.value(null);
    });
    navigationChannel.invokeMethod('ready');
  }

  void onPageChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onUpdateCurrentIndexPageView(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();
    return FutureBuilder(
        future: loadAsync,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return sessionModel
              .language((BuildContext context, String lang, Widget? child) {
            Localization.locale = lang;
            return Scaffold(
              body: PageView(
                onPageChanged: onPageChange,
                controller: _pageController,
                children: [
                  VPNTab(),
                  ExchangeTab(),
                  AccountTab(),
                ],
              ),
              bottomNavigationBar: CustomBottomBar(
                currentIndex: _currentIndex,
                updateCurrentIndexPageView: onUpdateCurrentIndexPageView,
              ),
            );
          });
        });
  }
}
