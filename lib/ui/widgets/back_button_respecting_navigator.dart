import 'package:lantern/package_store.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

/// BackButtonRespectingNavigator returns a Navigator that respects the hardware
/// back button, even if nested inside other navigators or having its own nested
/// navigators.
Widget BackButtonRespectingNavigator({required RouteFactory onGenerateRoute}) {
  return WillPopScope(
      onWillPop: () {
        final navigator = _navigatorKey.currentState;
        assert(navigator != null);
        return navigator!.maybePop().then((value) => !value);
      },
      child: Navigator(key: _navigatorKey, onGenerateRoute: onGenerateRoute));
}
