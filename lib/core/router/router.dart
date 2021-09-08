import 'package:auto_route/auto_route.dart';
import 'package:lantern/config/transitions.dart';
import 'package:lantern/core/router/tabs/account_tab_router.dart';
import 'package:lantern/core/router/tabs/developer_tab_router.dart';
import 'package:lantern/core/router/tabs/vpn_tab_router.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/new_message.dart';
import 'package:lantern/ui/home.dart';
import 'package:lantern/ui/widgets/full_screen_dialog.dart';
import 'package:lantern/messaging/introduce.dart';
import 'package:lantern/messaging/introductions.dart';
import 'package:lantern/messaging/messages.dart';
import 'package:lantern/messaging/your_contact_info.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AutoRoute(
      initial: true,
      name: 'Home',
      page: HomePage,
      path: '/',
      children: [
        vpn_tab_router,
        account_tab_router,
        developer_tab_router,
      ],
    ),
    CustomRoute<void>(
        page: FullScreenDialog,
        name: 'FullScreenDialogPage',
        path: 'fullScreenDialogPage',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Messages,
        path: '',
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
    CustomRoute<void>(
        page: NewMessage,
        name: 'NewMessage',
        path: 'newMessage',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Introduce,
        name: 'Introduce',
        path: 'introduce',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Introductions,
        name: 'Introductions',
        path: 'introductions',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    // we will anyways get rid of this soon
    CustomRoute<void>(
        page: YourContactInfo,
        name: 'ContactInfo',
        path: 'contactInfo',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
)
class $AppRouter {}
