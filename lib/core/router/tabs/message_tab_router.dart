import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/messaging/display_name.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/messaging/messages.dart';

const message_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'MessagesRouter',
  path: 'messages',
  children: [
    CustomRoute<void>(
        page: Messages,
        path: '',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: DisplayName,
        name: 'DisplayName',
        path: 'displayName',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
