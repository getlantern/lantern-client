import 'package:auto_route/auto_route.dart';
import 'package:lantern/account/account_management.dart';
import 'package:lantern/account/account_tab.dart';
import 'package:lantern/account/blocked_users.dart';
import 'package:lantern/account/device_linking/approve_device.dart';
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart';
import 'package:lantern/account/device_linking/authorize_device_via_email.dart';
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart';
import 'package:lantern/account/language.dart';
import 'package:lantern/account/settings.dart';
import 'package:lantern/common/ui/transitions.dart';

const account_tab_router = CustomRoute<void>(
  page: EmptyRouterPage,
  name: 'AccountRouter',
  path: 'account',
  children: [
    CustomRoute<void>(
        page: AccountTab,
        name: 'Account',
        path: '',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: AccountManagement,
        name: 'AccountManagement',
        path: 'accountManagement',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Settings,
        name: 'Settings',
        path: 'settings',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: Language,
        name: 'Language',
        path: 'language',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: AuthorizeDeviceForPro,
        name: 'AuthorizePro',
        path: 'authorizePro',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: AuthorizeDeviceViaEmail,
        name: 'AuthorizeDeviceEmail',
        path: 'authorizeDeviceEmail',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: AuthorizeDeviceViaEmailPin,
        name: 'AuthorizeDeviceEmailPin',
        path: 'authorizeDeviceEmailPin',
        transitionsBuilder: defaultTransition,
        durationInMilliseconds: defaultTransitionMillis,
        reverseDurationInMilliseconds: defaultTransitionMillis),
    CustomRoute<void>(
        page: ApproveDevice,
        name: 'ApproveDevice',
        path: 'approveDevice',
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
);
