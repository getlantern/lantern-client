import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/routes.dart';

import 'vpn.dart';

class HomePage extends StatefulWidget {
  final String _initialRoute;
  final dynamic _initialRouteArguments;

  HomePage(this._initialRoute, this._initialRouteArguments, {Key key})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(_initialRoute);
}

class _HomePageState extends State<HomePage> {
  PageController _pageController;
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
    _handleNavigationRequestsFromNative();
  }

  void _handleNavigationRequestsFromNative() {
    var navigationChannel = MethodChannel('navigation');
    navigationChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case "openConversation":
          Navigator.pushNamed(context, '/messaging/conversation',
              arguments: Contact.fromBuffer(call.arguments as Uint8List));
          break;
        default:
          throw Exception("unknown navigation method ${call.method}");
      }
      return null;
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

  onUpdateCurrentIndexPageView(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: onPageChange,
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        // TODO: only disable scrolling while we need to detect the drag gesture for the record button
        children: [
          MessagesTab(_initialRoute.replaceFirst(routeMessaging, ''),
              widget._initialRouteArguments),
          VPNTab(),
          Center(child: Text("Need to build this")),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        updateCurrentIndexPageView: onUpdateCurrentIndexPageView,
      ),
    );
  }
}
