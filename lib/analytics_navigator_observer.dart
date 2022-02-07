import 'package:lantern/common/common.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    trackRoute(newRoute);
  }

  void trackRoute(Route<dynamic>? route) {
    if (route != null) {
      final name = route.settings.name;
      if (name != null) {
        sessionModel.trackScreenView(name);
      }
    }
  }
}
