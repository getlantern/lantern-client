import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/replica/ui/replica_home_screen.dart';

const replica_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'ReplicaRouter',
  path: 'replica',
  children: [
    CustomRoute<String>(
        page: ReplicaHomeScreen,
        name: 'Replica',
        path: '',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
