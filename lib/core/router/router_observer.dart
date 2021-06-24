import 'package:auto_route/auto_route.dart';

class RouterObserver extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (router.canPopSelfOrChildren) {
      resolver.next(true);
    } else {
      print('no hijos');
      resolver.next(true);
    }
  }
}
