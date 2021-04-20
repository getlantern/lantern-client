import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:lantern/event/Event.dart';
import 'package:lantern/event/EventManager.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/routes.dart';
import 'package:lantern/utils/hex_color.dart';

import 'vpn.dart';

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

  _HomePageState(this._initialRoute) {
    if (_initialRoute.startsWith(routeVPN)) {
      _currentIndex = 1;
    } else if (_initialRoute.startsWith(routeSettings)) {
      _currentIndex = 2;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    final mainMethodChannel = const MethodChannel('lantern_method_channel');
    final eventManager = EventManager('lantern_event_channel');

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
        case 'openConversation':
          Navigator.pushNamed(context, '/messaging/conversation',
              arguments: Contact.fromBuffer(call.arguments as Uint8List));
          break;
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
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 100), curve: Curves.bounceIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: onPageChange,
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        // TODO: only disable scrolling while we need to detect the drag gesture for the record button
        children: [
          MessagesTab(_initialRoute.replaceFirst(routeMessaging, ''),
              widget._initialRouteArguments),
          VPNTab(),
          const Center(child: Text('Need to build this')),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        updateCurrentIndexPageView: onUpdateCurrentIndexPageView,
      ),
    );
  }
}
