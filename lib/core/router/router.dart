import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/tabs/account_tab_router.dart';
import 'package:lantern/core/router/tabs/developer_tab_router.dart';
import 'package:lantern/core/router/tabs/message_tab_router.dart';
import 'package:lantern/core/router/tabs/vpn_tab_router.dart';
import 'package:lantern/ui/home.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AutoRoute(
      initial: true,
      name: 'home',
      page: HomePage,
      path: '/',
      children: [
        message_tab_router,
        vpn_tab_router,
        account_tab_router,
        developer_tab_router,
      ],
    ),
  ],
)
class $AppRouter {}
