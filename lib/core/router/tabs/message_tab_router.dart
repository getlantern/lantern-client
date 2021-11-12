import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/messaging/chats.dart';

const message_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'MessagesRouter',
  path: 'messages',
  children: [
    CustomRoute<void>(
        initial: true,
        page: Chats,
        path: '',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
