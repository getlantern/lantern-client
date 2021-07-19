import 'package:auto_route/auto_route.dart';
import 'package:lantern/config/transitions.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/messages.dart';
import 'package:lantern/messaging/new_message.dart';
import 'package:lantern/messaging/your_contact_info.dart';

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
        page: YourContactInfo,
        name: 'ContactInfo',
        path: 'contactInfo',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: NewMessage,
        name: 'NewMessage',
        path: 'newMessage',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Conversation,
        name: 'Conversation',
        path: 'conversation',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
