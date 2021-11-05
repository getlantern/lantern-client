import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/messaging/chats.dart';
import 'package:lantern/messaging/onboarding_handler.dart';
import 'package:lantern/messaging/onboarding/welcome.dart';
import 'package:lantern/messaging/onboarding/secure_chat_number.dart';
import 'package:lantern/messaging/onboarding/secure_chat_number_recovery.dart';

const message_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'MessagesRouter',
  path: 'messages',
  children: [
    CustomRoute<void>(
        page: OnboardingHandler,
        path: '',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Chats,
        name: 'Chats',
        path: 'chats',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Welcome,
        name: 'Welcome',
        path: 'welcome',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: SecureChatNumber,
        name: 'SecureChatNumber',
        path: 'secureChatNumber',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: SecureNumberRecovery,
        name: 'SecureNumberRecovery',
        path: 'secureNumberRecovery',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
