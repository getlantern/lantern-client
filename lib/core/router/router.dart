import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/core/router/tabs/account_tab_router.dart';
import 'package:lantern/core/router/tabs/developer_tab_router.dart';
import 'package:lantern/core/router/tabs/message_tab_router.dart';
import 'package:lantern/core/router/tabs/onboarding_router.dart';
import 'package:lantern/core/router/tabs/vpn_tab_router.dart';
import 'package:lantern/home.dart';
import 'package:lantern/common/ui/full_screen_dialog.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AutoRoute(
      initial: true,
      name: 'Home',
      page: HomePage,
      path: '/',
      children: [
        onboarding_router,
        message_tab_router,
        vpn_tab_router,
        account_tab_router,
        developer_tab_router,
      ],
    ),
    CustomRoute<void>(
        page: FullScreenDialog,
        name: 'FullScreenDialogPage',
        path: 'fullScreenDialogPage',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
)
class $AppRouter {}
