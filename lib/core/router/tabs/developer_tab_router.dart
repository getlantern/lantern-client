import 'package:auto_route/auto_route.dart';
import 'package:lantern/ui/widgets/account/developer_settings.dart';

const developer_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'DeveloperRoute',
  path: 'developer',
  children: [
    CustomRoute<void>(
        page: DeveloperSettingsTab,
        name: 'developerSetting',
        path: '',
        transitionsBuilder: TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450),
  ],
);
