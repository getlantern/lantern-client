import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/introducing.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/vpn/vpn_tab.dart';

const vpn_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'VpnRouter',
  path: 'vpn',
  children: [
    CustomRoute<void>(
        page: VPNTab,
        name: 'Vpn',
        path: '',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Introducing,
        name: 'Introducing',
        path: 'introducing',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
