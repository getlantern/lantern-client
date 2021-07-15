import 'package:auto_route/auto_route.dart';
import 'package:lantern/config/transitions.dart';
import 'package:lantern/ui/widgets/vpn/vpn.dart';

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
  ],
);
