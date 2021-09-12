import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/transitions.dart';
import 'package:lantern/account/developer_settings.dart';

const developer_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'DeveloperRoute',
  path: 'developer',
  children: [
    CustomRoute<void>(
        page: DeveloperSettingsTab,
        name: 'DeveloperSettings',
        path: '',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
