import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/blocked_users.dart';
import 'package:lantern/account/recovery_key.dart';
import 'package:lantern/account/secure_chat_number_account.dart';
import 'package:lantern/common/ui/full_screen_dialog.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/core/router/tabs/account_tab_router.dart';
import 'package:lantern/core/router/tabs/developer_tab_router.dart';
import 'package:lantern/core/router/tabs/message_tab_router.dart';
import 'package:lantern/core/router/tabs/onboarding_router.dart';
import 'package:lantern/core/router/tabs/vpn_tab_router.dart';
import 'package:lantern/home.dart';
import 'package:lantern/messaging/contacts/add_contact_number.dart';
import 'package:lantern/messaging/contacts/contact_info.dart';
import 'package:lantern/messaging/contacts/new_chat.dart';
import 'package:lantern/messaging/conversation/conversation.dart';
import 'package:lantern/messaging/introductions/introduce.dart';
import 'package:lantern/messaging/introductions/introductions.dart';

@AdaptiveAutoRouter(
  replaceInRouteName: 'Page,Route,Screen',
  routes: <AutoRoute>[
    AutoRoute(
      initial: true,
      name: 'Home',
      page: HomePage,
      path: '/',
      children: [
        onboarding_router,
        message_tab_router,
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
        page: Conversation,
        name: 'Conversation',
        path: 'conversation',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: ContactInfo,
        name: 'ContactInfo',
        path: 'contactInfo',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: NewChat,
        name: 'NewChat',
        path: 'newChat',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: AddViaChatNumber,
        name: 'AddViaChatNumber',
        path: 'addViaChatNumber',
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
    CustomRoute<void>(
        page: RecoveryKey,
        name: 'RecoveryKey',
        path: 'recoveryKey',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: SecureChatNumberAccount,
        name: 'SecureChatNumberAccount',
        path: 'secureChatNumberAccount',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: BlockedUsers,
        name: 'BlockedUsers',
        path: 'blockedUsers',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
)
class $AppRouter {}
