import 'package:auto_route/auto_route.dart';
import 'package:lantern/ui/widgets/vpn/vpn.dart';

const vpn_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'VpnRouter',
  path: 'vpn',
  children: [
    CustomRoute<void>(
        page: VPNTab,
        name: 'vpn',
        path: '',
        transitionsBuilder: TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450),
  ],
);
