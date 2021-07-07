import 'package:auto_route/auto_route.dart';
import 'package:lantern/messaging/add_contact_QR.dart';
import 'package:lantern/messaging/add_contact_username.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/conversations.dart';
import 'package:lantern/messaging/new_message.dart';
import 'package:lantern/messaging/your_contact_info.dart';

const message_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'MessagesRouter',
  path: 'messages',
  children: [
    CustomRoute<void>(
        page: Conversations,
        path: '',
        transitionsBuilder: TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450),
    CustomRoute<void>(
        page: YourContactInfo,
        name: 'contactInfo',
        path: 'contactInfo',
        transitionsBuilder: TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450),
    CustomRoute<void>(
        page: NewMessage,
        name: 'newMessage',
        path: 'newMessage',
        transitionsBuilder: TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450),
    CustomRoute<void>(
        page: AddViaQR,
        name: 'addQR',
        path: 'addQR',
        transitionsBuilder: TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450),
    CustomRoute<void>(
        page: AddViaUsername,
        name: 'addUsername',
        path: 'addUsername',
        transitionsBuilder: TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450),
    CustomRoute<void>(
        page: Conversation,
        name: 'conversation',
        path: 'conversation',
        transitionsBuilder: TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450),
  ],
);
