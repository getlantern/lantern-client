import 'package:auto_route/auto_route.dart';
import 'package:lantern/ui/index.dart';
import 'package:lantern/ui/widgets/account/developer_settings.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AdaptiveRoute<void>(
      initial: true,
      name: 'main',
      page: HomePage,
      path: '/main',
      children: [
        CustomRoute<void>(
          page: MessagesTab,
          name: 'messages',
          path: 'messages',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          durationInMilliseconds: 400,
        ),
        CustomRoute<void>(
          page: VPNTab,
          name: 'vpn',
          path: 'vpn',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          durationInMilliseconds: 400,
        ),
        CustomRoute<void>(
          page: AccountTab,
          name: 'account',
          path: 'account',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          durationInMilliseconds: 400,
        ),
        CustomRoute<void>(
          page: DeveloperSettingsTab,
          name: 'developer',
          path: 'developer',
          transitionsBuilder: TransitionsBuilders.fadeIn,
          durationInMilliseconds: 400,
        ),
      ],
    ),
  ],
)
class $AppRouter {}
