import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/account_tab.dart';
import 'package:lantern/common/ui/transitions.dart';

const account_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'AccountRouter',
  path: 'account',
  children: [
    CustomRoute<void>(
        page: AccountTab,
        name: 'Account',
        path: '',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
