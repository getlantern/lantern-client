import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/ui/transitions.dart';
import 'package:lantern/messaging/onboarding/secure_chat_number_messaging.dart';
import 'package:lantern/messaging/onboarding/secure_chat_number_recovery.dart';
import 'package:lantern/messaging/onboarding/welcome.dart';

const onboarding_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'OnboardingRouter',
  path: 'onboarding',
  children: [
    CustomRoute<void>(
        initial: true,
        page: Welcome,
        name: 'Welcome',
        path: 'welcome',
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
    CustomRoute<void>(
        page: SecureChatNumberMessaging,
        name: 'SecureChatNumberMessaging',
        path: 'secureChatNumberMessaging',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
  ],
);
