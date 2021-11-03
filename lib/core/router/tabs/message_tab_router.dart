import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/messaging/chats.dart';
import 'package:lantern/messaging/onboarding/welcome.dart';

const message_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'MessagesRouter',
  path: 'chats',
  children: [
    CustomRoute<void>(
        page: Chats,
        path: '',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
