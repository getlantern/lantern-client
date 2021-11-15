// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i11;
import 'package:flutter/material.dart' as _i26;
import 'package:lantern/account/account_management.dart' as _i18;
import 'package:lantern/account/account_tab.dart' as _i17;
import 'package:lantern/account/developer_settings.dart' as _i25;
import 'package:lantern/account/device_linking/approve_device.dart' as _i24;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i21;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i22;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i23;
import 'package:lantern/account/language.dart' as _i20;
import 'package:lantern/account/recovery_key.dart' as _i9;
import 'package:lantern/account/secure_chat_number_account.dart' as _i10;
import 'package:lantern/account/settings.dart' as _i19;
import 'package:lantern/common/common.dart' as _i27;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i2;
import 'package:lantern/home.dart' as _i1;
import 'package:lantern/messaging/chats.dart' as _i15;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i6;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i4;
import 'package:lantern/messaging/contacts/new_chat.dart' as _i5;
import 'package:lantern/messaging/conversation/conversation.dart' as _i3;
import 'package:lantern/messaging/introductions/introduce.dart' as _i7;
import 'package:lantern/messaging/introductions/introductions.dart' as _i8;
import 'package:lantern/messaging/messaging.dart' as _i28;
import 'package:lantern/messaging/onboarding/secure_chat_number_messaging.dart'
    as _i14;
import 'package:lantern/messaging/onboarding/secure_chat_number_recovery.dart'
    as _i13;
import 'package:lantern/messaging/onboarding/welcome.dart' as _i12;
import 'package:lantern/vpn/vpn_tab.dart' as _i16;

class AppRouter extends _i11.RootStackRouter {
  AppRouter([_i26.GlobalKey<_i26.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i11.PageFactory> pagesMap = {
    Home.name: (routeData) {
      final args = routeData.argsAs<HomeArgs>(orElse: () => const HomeArgs());
      return _i11.AdaptivePage<dynamic>(
          routeData: routeData, child: _i1.HomePage(key: args.key));
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i2.FullScreenDialog(widget: args.widget, key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i3.Conversation(
              contactId: args.contactId,
              initialScrollIndex: args.initialScrollIndex,
              showContactEditingDialog: args.showContactEditingDialog),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i4.ContactInfo(model: args.model, contact: args.contact),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    NewChat.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i5.NewChat(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AddViaChatNumber.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i6.AddViaChatNumber(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introduce.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i7.Introduce(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introductions.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i8.Introductions(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    RecoveryKey.name: (routeData) {
      final args = routeData.argsAs<RecoveryKeyArgs>(
          orElse: () => const RecoveryKeyArgs());
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i9.RecoveryKey(key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    SecureChatNumberAccount.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i10.SecureChatNumberAccount(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    OnboardingRouter.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: const _i11.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    MessagesRouter.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: const _i11.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    VpnRouter.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: const _i11.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    AccountRouter.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: const _i11.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    DeveloperRoute.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: const _i11.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    Welcome.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i12.Welcome(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    SecureNumberRecovery.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i13.SecureNumberRecovery(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    SecureChatNumberMessaging.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i14.SecureChatNumberMessaging(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ChatsRoute.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i15.Chats(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Vpn.name: (routeData) {
      final args = routeData.argsAs<VpnArgs>(orElse: () => const VpnArgs());
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i16.VPNTab(key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Account.name: (routeData) {
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i17.AccountTab(),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AccountManagement.name: (routeData) {
      final args = routeData.argsAs<AccountManagementArgs>();
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i18.AccountManagement(key: args.key, isPro: args.isPro),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i19.Settings(key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i20.Language(key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizePro.name: (routeData) {
      final args = routeData.argsAs<AuthorizeProArgs>(
          orElse: () => const AuthorizeProArgs());
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i21.AuthorizeDeviceForPro(key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i22.AuthorizeDeviceViaEmail(key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>(
          orElse: () => const AuthorizeDeviceEmailPinArgs());
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i23.AuthorizeDeviceViaEmailPin(key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i24.ApproveDevice(key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    DeveloperSettings.name: (routeData) {
      final args = routeData.argsAs<DeveloperSettingsArgs>(
          orElse: () => const DeveloperSettingsArgs());
      return _i11.CustomPage<void>(
          routeData: routeData,
          child: _i25.DeveloperSettingsTab(key: args.key),
          transitionsBuilder: _i11.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    }
  };

  @override
  List<_i11.RouteConfig> get routes => [
        _i11.RouteConfig(Home.name, path: '/', children: [
          _i11.RouteConfig(OnboardingRouter.name,
              path: 'onboarding',
              parent: Home.name,
              children: [
                _i11.RouteConfig('#redirect',
                    path: '',
                    parent: OnboardingRouter.name,
                    redirectTo: 'welcome',
                    fullMatch: true),
                _i11.RouteConfig(Welcome.name,
                    path: 'welcome', parent: OnboardingRouter.name),
                _i11.RouteConfig(SecureNumberRecovery.name,
                    path: 'secureNumberRecovery',
                    parent: OnboardingRouter.name),
                _i11.RouteConfig(SecureChatNumberMessaging.name,
                    path: 'secureChatNumberMessaging',
                    parent: OnboardingRouter.name)
              ]),
          _i11.RouteConfig(MessagesRouter.name,
              path: 'messages',
              parent: Home.name,
              children: [
                _i11.RouteConfig(ChatsRoute.name,
                    path: '', parent: MessagesRouter.name)
              ]),
          _i11.RouteConfig(VpnRouter.name,
              path: 'vpn',
              parent: Home.name,
              children: [
                _i11.RouteConfig(Vpn.name, path: '', parent: VpnRouter.name)
              ]),
          _i11.RouteConfig(AccountRouter.name,
              path: 'account',
              parent: Home.name,
              children: [
                _i11.RouteConfig(Account.name,
                    path: '', parent: AccountRouter.name),
                _i11.RouteConfig(AccountManagement.name,
                    path: 'accountManagement', parent: AccountRouter.name),
                _i11.RouteConfig(Settings.name,
                    path: 'settings', parent: AccountRouter.name),
                _i11.RouteConfig(Language.name,
                    path: 'language', parent: AccountRouter.name),
                _i11.RouteConfig(AuthorizePro.name,
                    path: 'authorizePro', parent: AccountRouter.name),
                _i11.RouteConfig(AuthorizeDeviceEmail.name,
                    path: 'authorizeDeviceEmail', parent: AccountRouter.name),
                _i11.RouteConfig(AuthorizeDeviceEmailPin.name,
                    path: 'authorizeDeviceEmailPin',
                    parent: AccountRouter.name),
                _i11.RouteConfig(ApproveDevice.name,
                    path: 'approveDevice', parent: AccountRouter.name)
              ]),
          _i11.RouteConfig(DeveloperRoute.name,
              path: 'developer',
              parent: Home.name,
              children: [
                _i11.RouteConfig(DeveloperSettings.name,
                    path: '', parent: DeveloperRoute.name)
              ])
        ]),
        _i11.RouteConfig(FullScreenDialogPage.name,
            path: 'fullScreenDialogPage'),
        _i11.RouteConfig(Conversation.name, path: 'conversation'),
        _i11.RouteConfig(ContactInfo.name, path: 'contactInfo'),
        _i11.RouteConfig(NewChat.name, path: 'newChat'),
        _i11.RouteConfig(AddViaChatNumber.name, path: 'addViaChatNumber'),
        _i11.RouteConfig(Introduce.name, path: 'introduce'),
        _i11.RouteConfig(Introductions.name, path: 'introductions'),
        _i11.RouteConfig(RecoveryKey.name, path: 'recoveryKey'),
        _i11.RouteConfig(SecureChatNumberAccount.name,
            path: 'secureChatNumberAccount')
      ];
}

/// generated route for [_i1.HomePage]
class Home extends _i11.PageRouteInfo<HomeArgs> {
  Home({_i27.Key? key, List<_i11.PageRouteInfo>? children})
      : super(name,
            path: '/', args: HomeArgs(key: key), initialChildren: children);

  static const String name = 'Home';
}

class HomeArgs {
  const HomeArgs({this.key});

  final _i27.Key? key;
}

/// generated route for [_i2.FullScreenDialog]
class FullScreenDialogPage
    extends _i11.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({required _i27.Widget widget, _i27.Key? key})
      : super(name,
            path: 'fullScreenDialogPage',
            args: FullScreenDialogPageArgs(widget: widget, key: key));

  static const String name = 'FullScreenDialogPage';
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({required this.widget, this.key});

  final _i27.Widget widget;

  final _i27.Key? key;
}

/// generated route for [_i3.Conversation]
class Conversation extends _i11.PageRouteInfo<ConversationArgs> {
  Conversation(
      {required _i28.ContactId contactId,
      int? initialScrollIndex,
      bool? showContactEditingDialog})
      : super(name,
            path: 'conversation',
            args: ConversationArgs(
                contactId: contactId,
                initialScrollIndex: initialScrollIndex,
                showContactEditingDialog: showContactEditingDialog));

  static const String name = 'Conversation';
}

class ConversationArgs {
  const ConversationArgs(
      {required this.contactId,
      this.initialScrollIndex,
      this.showContactEditingDialog});

  final _i28.ContactId contactId;

  final int? initialScrollIndex;

  final bool? showContactEditingDialog;
}

/// generated route for [_i4.ContactInfo]
class ContactInfo extends _i11.PageRouteInfo<ContactInfoArgs> {
  ContactInfo(
      {required _i28.MessagingModel model, required _i28.Contact contact})
      : super(name,
            path: 'contactInfo',
            args: ContactInfoArgs(model: model, contact: contact));

  static const String name = 'ContactInfo';
}

class ContactInfoArgs {
  const ContactInfoArgs({required this.model, required this.contact});

  final _i28.MessagingModel model;

  final _i28.Contact contact;
}

/// generated route for [_i5.NewChat]
class NewChat extends _i11.PageRouteInfo<void> {
  const NewChat() : super(name, path: 'newChat');

  static const String name = 'NewChat';
}

/// generated route for [_i6.AddViaChatNumber]
class AddViaChatNumber extends _i11.PageRouteInfo<void> {
  const AddViaChatNumber() : super(name, path: 'addViaChatNumber');

  static const String name = 'AddViaChatNumber';
}

/// generated route for [_i7.Introduce]
class Introduce extends _i11.PageRouteInfo<void> {
  const Introduce() : super(name, path: 'introduce');

  static const String name = 'Introduce';
}

/// generated route for [_i8.Introductions]
class Introductions extends _i11.PageRouteInfo<void> {
  const Introductions() : super(name, path: 'introductions');

  static const String name = 'Introductions';
}

/// generated route for [_i9.RecoveryKey]
class RecoveryKey extends _i11.PageRouteInfo<RecoveryKeyArgs> {
  RecoveryKey({_i27.Key? key})
      : super(name, path: 'recoveryKey', args: RecoveryKeyArgs(key: key));

  static const String name = 'RecoveryKey';
}

class RecoveryKeyArgs {
  const RecoveryKeyArgs({this.key});

  final _i27.Key? key;
}

/// generated route for [_i10.SecureChatNumberAccount]
class SecureChatNumberAccount extends _i11.PageRouteInfo<void> {
  const SecureChatNumberAccount()
      : super(name, path: 'secureChatNumberAccount');

  static const String name = 'SecureChatNumberAccount';
}

/// generated route for [_i11.EmptyRouterPage]
class OnboardingRouter extends _i11.PageRouteInfo<void> {
  const OnboardingRouter({List<_i11.PageRouteInfo>? children})
      : super(name, path: 'onboarding', initialChildren: children);

  static const String name = 'OnboardingRouter';
}

/// generated route for [_i11.EmptyRouterPage]
class MessagesRouter extends _i11.PageRouteInfo<void> {
  const MessagesRouter({List<_i11.PageRouteInfo>? children})
      : super(name, path: 'messages', initialChildren: children);

  static const String name = 'MessagesRouter';
}

/// generated route for [_i11.EmptyRouterPage]
class VpnRouter extends _i11.PageRouteInfo<void> {
  const VpnRouter({List<_i11.PageRouteInfo>? children})
      : super(name, path: 'vpn', initialChildren: children);

  static const String name = 'VpnRouter';
}

/// generated route for [_i11.EmptyRouterPage]
class AccountRouter extends _i11.PageRouteInfo<void> {
  const AccountRouter({List<_i11.PageRouteInfo>? children})
      : super(name, path: 'account', initialChildren: children);

  static const String name = 'AccountRouter';
}

/// generated route for [_i11.EmptyRouterPage]
class DeveloperRoute extends _i11.PageRouteInfo<void> {
  const DeveloperRoute({List<_i11.PageRouteInfo>? children})
      : super(name, path: 'developer', initialChildren: children);

  static const String name = 'DeveloperRoute';
}

/// generated route for [_i12.Welcome]
class Welcome extends _i11.PageRouteInfo<void> {
  const Welcome() : super(name, path: 'welcome');

  static const String name = 'Welcome';
}

/// generated route for [_i13.SecureNumberRecovery]
class SecureNumberRecovery extends _i11.PageRouteInfo<void> {
  const SecureNumberRecovery() : super(name, path: 'secureNumberRecovery');

  static const String name = 'SecureNumberRecovery';
}

/// generated route for [_i14.SecureChatNumberMessaging]
class SecureChatNumberMessaging extends _i11.PageRouteInfo<void> {
  const SecureChatNumberMessaging()
      : super(name, path: 'secureChatNumberMessaging');

  static const String name = 'SecureChatNumberMessaging';
}

/// generated route for [_i15.Chats]
class ChatsRoute extends _i11.PageRouteInfo<void> {
  const ChatsRoute() : super(name, path: '');

  static const String name = 'ChatsRoute';
}

/// generated route for [_i16.VPNTab]
class Vpn extends _i11.PageRouteInfo<VpnArgs> {
  Vpn({_i27.Key? key}) : super(name, path: '', args: VpnArgs(key: key));

  static const String name = 'Vpn';
}

class VpnArgs {
  const VpnArgs({this.key});

  final _i27.Key? key;
}

/// generated route for [_i17.AccountTab]
class Account extends _i11.PageRouteInfo<void> {
  const Account() : super(name, path: '');

  static const String name = 'Account';
}

/// generated route for [_i18.AccountManagement]
class AccountManagement extends _i11.PageRouteInfo<AccountManagementArgs> {
  AccountManagement({_i27.Key? key, required bool isPro})
      : super(name,
            path: 'accountManagement',
            args: AccountManagementArgs(key: key, isPro: isPro));

  static const String name = 'AccountManagement';
}

class AccountManagementArgs {
  const AccountManagementArgs({this.key, required this.isPro});

  final _i27.Key? key;

  final bool isPro;
}

/// generated route for [_i19.Settings]
class Settings extends _i11.PageRouteInfo<SettingsArgs> {
  Settings({_i27.Key? key})
      : super(name, path: 'settings', args: SettingsArgs(key: key));

  static const String name = 'Settings';
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i27.Key? key;
}

/// generated route for [_i20.Language]
class Language extends _i11.PageRouteInfo<LanguageArgs> {
  Language({_i27.Key? key})
      : super(name, path: 'language', args: LanguageArgs(key: key));

  static const String name = 'Language';
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i27.Key? key;
}

/// generated route for [_i21.AuthorizeDeviceForPro]
class AuthorizePro extends _i11.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({_i27.Key? key})
      : super(name, path: 'authorizePro', args: AuthorizeProArgs(key: key));

  static const String name = 'AuthorizePro';
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i27.Key? key;
}

/// generated route for [_i22.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail
    extends _i11.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({_i27.Key? key})
      : super(name,
            path: 'authorizeDeviceEmail',
            args: AuthorizeDeviceEmailArgs(key: key));

  static const String name = 'AuthorizeDeviceEmail';
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i27.Key? key;
}

/// generated route for [_i23.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i11.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({_i27.Key? key})
      : super(name,
            path: 'authorizeDeviceEmailPin',
            args: AuthorizeDeviceEmailPinArgs(key: key));

  static const String name = 'AuthorizeDeviceEmailPin';
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i27.Key? key;
}

/// generated route for [_i24.ApproveDevice]
class ApproveDevice extends _i11.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({_i27.Key? key})
      : super(name, path: 'approveDevice', args: ApproveDeviceArgs(key: key));

  static const String name = 'ApproveDevice';
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i27.Key? key;
}

/// generated route for [_i25.DeveloperSettingsTab]
class DeveloperSettings extends _i11.PageRouteInfo<DeveloperSettingsArgs> {
  DeveloperSettings({_i27.Key? key})
      : super(name, path: '', args: DeveloperSettingsArgs(key: key));

  static const String name = 'DeveloperSettings';
}

class DeveloperSettingsArgs {
  const DeveloperSettingsArgs({this.key});

  final _i27.Key? key;
}
