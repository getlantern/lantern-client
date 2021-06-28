import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';

class RouterObserver extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    print("current route name:${router.current.name}");
    print("resolve route name:${resolver.route.routeName}");
    print("route name args: ${resolver.route.args.toString()}");
    print("is root route name: ${router.isRoot}");
    //if (router.canPopSelfOrChildren) {
    resolver.next(true);
    //} else {
    //  print('no hijos');
    //  router.push(Home());
    // }
  }
}
