// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i19;
import 'package:flutter/material.dart' as _i27;
import 'package:lantern/account/account_management.dart' as _i9;
import 'package:lantern/account/account_tab.dart' as _i25;
import 'package:lantern/account/blocked_users.dart' as _i18;
import 'package:lantern/account/developer_settings.dart' as _i26;
import 'package:lantern/account/device_linking/approve_device.dart' as _i15;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i12;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i13;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i14;
import 'package:lantern/account/language.dart' as _i11;
import 'package:lantern/account/recovery_key.dart' as _i16;
import 'package:lantern/account/secure_chat_number_account.dart' as _i17;
import 'package:lantern/account/settings.dart' as _i10;
import 'package:lantern/common/common.dart' as _i28;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i2;
import 'package:lantern/home.dart' as _i1;
import 'package:lantern/messaging/chats.dart' as _i23;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i6;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i4;
import 'package:lantern/messaging/contacts/new_chat.dart' as _i5;
import 'package:lantern/messaging/conversation/conversation.dart' as _i3;
import 'package:lantern/messaging/introductions/introduce.dart' as _i7;
import 'package:lantern/messaging/introductions/introductions.dart' as _i8;
import 'package:lantern/messaging/messaging.dart' as _i29;
import 'package:lantern/messaging/messaging_model.dart' as _i30;
import 'package:lantern/messaging/onboarding/secure_chat_number_messaging.dart'
    as _i22;
import 'package:lantern/messaging/onboarding/secure_chat_number_recovery.dart'
    as _i21;
import 'package:lantern/messaging/onboarding/welcome.dart' as _i20;
import 'package:lantern/vpn/vpn_tab.dart' as _i24;

class AppRouter extends _i19.RootStackRouter {
  AppRouter([_i27.GlobalKey<_i27.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i19.PageFactory> pagesMap = {
    Home.name: (routeData) {
      final args = routeData.argsAs<HomeArgs>(orElse: () => const HomeArgs());
      return _i19.AdaptivePage<dynamic>(
          routeData: routeData, child: _i1.HomePage(key: args.key));
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i2.FullScreenDialog(widget: args.widget, key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i3.Conversation(
              contactId: args.contactId,
              initialScrollIndex: args.initialScrollIndex,
              showContactEditingDialog: args.showContactEditingDialog),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i4.ContactInfo(model: args.model, contact: args.contact),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    NewChat.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i5.NewChat(),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AddViaChatNumber.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i6.AddViaChatNumber(),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introduce.name: (routeData) {
      final args = routeData.argsAs<IntroduceArgs>();
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i7.Introduce(
              singleIntro: args.singleIntro,
              contactToIntro: args.contactToIntro),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introductions.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i8.Introductions(),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AccountManagement.name: (routeData) {
      final args = routeData.argsAs<AccountManagementArgs>();
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i9.AccountManagement(key: args.key, isPro: args.isPro),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i10.Settings(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i11.Language(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizePro.name: (routeData) {
      final args = routeData.argsAs<AuthorizeProArgs>(
          orElse: () => const AuthorizeProArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i12.AuthorizeDeviceForPro(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i13.AuthorizeDeviceViaEmail(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>(
          orElse: () => const AuthorizeDeviceEmailPinArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i14.AuthorizeDeviceViaEmailPin(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i15.ApproveDevice(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    RecoveryKey.name: (routeData) {
      final args = routeData.argsAs<RecoveryKeyArgs>(
          orElse: () => const RecoveryKeyArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i16.RecoveryKey(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    SecureChatNumberAccount.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i17.SecureChatNumberAccount(),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    BlockedUsers.name: (routeData) {
      final args = routeData.argsAs<BlockedUsersArgs>(
          orElse: () => const BlockedUsersArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i18.BlockedUsers(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    OnboardingRouter.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: const _i19.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    MessagesRouter.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: const _i19.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    VpnRouter.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: const _i19.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    AccountRouter.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: const _i19.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    DeveloperRoute.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: const _i19.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    Welcome.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i20.Welcome(),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    SecureNumberRecovery.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i21.SecureNumberRecovery(),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    SecureChatNumberMessaging.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i22.SecureChatNumberMessaging(),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ChatsRoute.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i23.Chats(),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Vpn.name: (routeData) {
      final args = routeData.argsAs<VpnArgs>(orElse: () => const VpnArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i24.VPNTab(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Account.name: (routeData) {
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i25.AccountTab(),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    DeveloperSettings.name: (routeData) {
      final args = routeData.argsAs<DeveloperSettingsArgs>(
          orElse: () => const DeveloperSettingsArgs());
      return _i19.CustomPage<void>(
          routeData: routeData,
          child: _i26.DeveloperSettingsTab(key: args.key),
          transitionsBuilder: _i19.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    }
  };

  @override
  List<_i19.RouteConfig> get routes => [
        _i19.RouteConfig(Home.name, path: '/', children: [
          _i19.RouteConfig(OnboardingRouter.name,
              path: 'onboarding',
              parent: Home.name,
              children: [
                _i19.RouteConfig('#redirect',
                    path: '',
                    parent: OnboardingRouter.name,
                    redirectTo: 'welcome',
                    fullMatch: true),
                _i19.RouteConfig(Welcome.name,
                    path: 'welcome', parent: OnboardingRouter.name),
                _i19.RouteConfig(SecureNumberRecovery.name,
                    path: 'secureNumberRecovery',
                    parent: OnboardingRouter.name),
                _i19.RouteConfig(SecureChatNumberMessaging.name,
                    path: 'secureChatNumberMessaging',
                    parent: OnboardingRouter.name)
              ]),
          _i19.RouteConfig(MessagesRouter.name,
              path: 'messages',
              parent: Home.name,
              children: [
                _i19.RouteConfig(ChatsRoute.name,
                    path: '', parent: MessagesRouter.name)
              ]),
          _i19.RouteConfig(VpnRouter.name,
              path: 'vpn',
              parent: Home.name,
              children: [
                _i19.RouteConfig(Vpn.name, path: '', parent: VpnRouter.name)
              ]),
          _i19.RouteConfig(AccountRouter.name,
              path: 'account',
              parent: Home.name,
              children: [
                _i19.RouteConfig(Account.name,
                    path: '', parent: AccountRouter.name)
              ]),
          _i19.RouteConfig(DeveloperRoute.name,
              path: 'developer',
              parent: Home.name,
              children: [
                _i19.RouteConfig(DeveloperSettings.name,
                    path: '', parent: DeveloperRoute.name)
              ])
        ]),
        _i19.RouteConfig(FullScreenDialogPage.name,
            path: 'fullScreenDialogPage'),
        _i19.RouteConfig(Conversation.name, path: 'conversation'),
        _i19.RouteConfig(ContactInfo.name, path: 'contactInfo'),
        _i19.RouteConfig(NewChat.name, path: 'newChat'),
        _i19.RouteConfig(AddViaChatNumber.name, path: 'addViaChatNumber'),
        _i19.RouteConfig(Introduce.name, path: 'introduce'),
        _i19.RouteConfig(Introductions.name, path: 'introductions'),
        _i19.RouteConfig(AccountManagement.name, path: 'accountManagement'),
        _i19.RouteConfig(Settings.name, path: 'settings'),
        _i19.RouteConfig(Language.name, path: 'language'),
        _i19.RouteConfig(AuthorizePro.name, path: 'authorizePro'),
        _i19.RouteConfig(AuthorizeDeviceEmail.name,
            path: 'authorizeDeviceEmail'),
        _i19.RouteConfig(AuthorizeDeviceEmailPin.name,
            path: 'authorizeDeviceEmailPin'),
        _i19.RouteConfig(ApproveDevice.name, path: 'approveDevice'),
        _i19.RouteConfig(RecoveryKey.name, path: 'recoveryKey'),
        _i19.RouteConfig(SecureChatNumberAccount.name,
            path: 'secureChatNumberAccount'),
        _i19.RouteConfig(BlockedUsers.name, path: 'blockedUsers')
      ];
}

/// generated route for [_i1.HomePage]
class Home extends _i19.PageRouteInfo<HomeArgs> {
  Home({_i28.Key? key, List<_i19.PageRouteInfo>? children})
      : super(name,
            path: '/', args: HomeArgs(key: key), initialChildren: children);

  static const String name = 'Home';
}

class HomeArgs {
  const HomeArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'HomeArgs{key: $key}';
  }
}

/// generated route for [_i2.FullScreenDialog]
class FullScreenDialogPage
    extends _i19.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({required _i28.Widget widget, _i28.Key? key})
      : super(name,
            path: 'fullScreenDialogPage',
            args: FullScreenDialogPageArgs(widget: widget, key: key));

  static const String name = 'FullScreenDialogPage';
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({required this.widget, this.key});

  final _i28.Widget widget;

  final _i28.Key? key;

  @override
  String toString() {
    return 'FullScreenDialogPageArgs{widget: $widget, key: $key}';
  }
}

/// generated route for [_i3.Conversation]
class Conversation extends _i19.PageRouteInfo<ConversationArgs> {
  Conversation(
      {required _i29.ContactId contactId,
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

  final _i29.ContactId contactId;

  final int? initialScrollIndex;

  final bool? showContactEditingDialog;

  @override
  String toString() {
    return 'ConversationArgs{contactId: $contactId, initialScrollIndex: $initialScrollIndex, showContactEditingDialog: $showContactEditingDialog}';
  }
}

/// generated route for [_i4.ContactInfo]
class ContactInfo extends _i19.PageRouteInfo<ContactInfoArgs> {
  ContactInfo(
      {required _i30.MessagingModel model, required _i29.Contact contact})
      : super(name,
            path: 'contactInfo',
            args: ContactInfoArgs(model: model, contact: contact));

  static const String name = 'ContactInfo';
}

class ContactInfoArgs {
  const ContactInfoArgs({required this.model, required this.contact});

  final _i30.MessagingModel model;

  final _i29.Contact contact;

  @override
  String toString() {
    return 'ContactInfoArgs{model: $model, contact: $contact}';
  }
}

/// generated route for [_i5.NewChat]
class NewChat extends _i19.PageRouteInfo<void> {
  const NewChat() : super(name, path: 'newChat');

  static const String name = 'NewChat';
}

/// generated route for [_i6.AddViaChatNumber]
class AddViaChatNumber extends _i19.PageRouteInfo<void> {
  const AddViaChatNumber() : super(name, path: 'addViaChatNumber');

  static const String name = 'AddViaChatNumber';
}

/// generated route for [_i7.Introduce]
class Introduce extends _i19.PageRouteInfo<IntroduceArgs> {
  Introduce({required bool singleIntro, _i29.Contact? contactToIntro})
      : super(name,
            path: 'introduce',
            args: IntroduceArgs(
                singleIntro: singleIntro, contactToIntro: contactToIntro));

  static const String name = 'Introduce';
}

class IntroduceArgs {
  const IntroduceArgs({required this.singleIntro, this.contactToIntro});

  final bool singleIntro;

  final _i29.Contact? contactToIntro;

  @override
  String toString() {
    return 'IntroduceArgs{singleIntro: $singleIntro, contactToIntro: $contactToIntro}';
  }
}

/// generated route for [_i8.Introductions]
class Introductions extends _i19.PageRouteInfo<void> {
  const Introductions() : super(name, path: 'introductions');

  static const String name = 'Introductions';
}

/// generated route for [_i9.AccountManagement]
class AccountManagement extends _i19.PageRouteInfo<AccountManagementArgs> {
  AccountManagement({_i28.Key? key, required bool isPro})
      : super(name,
            path: 'accountManagement',
            args: AccountManagementArgs(key: key, isPro: isPro));

  static const String name = 'AccountManagement';
}

class AccountManagementArgs {
  const AccountManagementArgs({this.key, required this.isPro});

  final _i28.Key? key;

  final bool isPro;

  @override
  String toString() {
    return 'AccountManagementArgs{key: $key, isPro: $isPro}';
  }
}

/// generated route for [_i10.Settings]
class Settings extends _i19.PageRouteInfo<SettingsArgs> {
  Settings({_i28.Key? key})
      : super(name, path: 'settings', args: SettingsArgs(key: key));

  static const String name = 'Settings';
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'SettingsArgs{key: $key}';
  }
}

/// generated route for [_i11.Language]
class Language extends _i19.PageRouteInfo<LanguageArgs> {
  Language({_i28.Key? key})
      : super(name, path: 'language', args: LanguageArgs(key: key));

  static const String name = 'Language';
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'LanguageArgs{key: $key}';
  }
}

/// generated route for [_i12.AuthorizeDeviceForPro]
class AuthorizePro extends _i19.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({_i28.Key? key})
      : super(name, path: 'authorizePro', args: AuthorizeProArgs(key: key));

  static const String name = 'AuthorizePro';
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'AuthorizeProArgs{key: $key}';
  }
}

/// generated route for [_i13.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail
    extends _i19.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({_i28.Key? key})
      : super(name,
            path: 'authorizeDeviceEmail',
            args: AuthorizeDeviceEmailArgs(key: key));

  static const String name = 'AuthorizeDeviceEmail';
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailArgs{key: $key}';
  }
}

/// generated route for [_i14.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i19.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({_i28.Key? key})
      : super(name,
            path: 'authorizeDeviceEmailPin',
            args: AuthorizeDeviceEmailPinArgs(key: key));

  static const String name = 'AuthorizeDeviceEmailPin';
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailPinArgs{key: $key}';
  }
}

/// generated route for [_i15.ApproveDevice]
class ApproveDevice extends _i19.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({_i28.Key? key})
      : super(name, path: 'approveDevice', args: ApproveDeviceArgs(key: key));

  static const String name = 'ApproveDevice';
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'ApproveDeviceArgs{key: $key}';
  }
}

/// generated route for [_i16.RecoveryKey]
class RecoveryKey extends _i19.PageRouteInfo<RecoveryKeyArgs> {
  RecoveryKey({_i28.Key? key})
      : super(name, path: 'recoveryKey', args: RecoveryKeyArgs(key: key));

  static const String name = 'RecoveryKey';
}

class RecoveryKeyArgs {
  const RecoveryKeyArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'RecoveryKeyArgs{key: $key}';
  }
}

/// generated route for [_i17.SecureChatNumberAccount]
class SecureChatNumberAccount extends _i19.PageRouteInfo<void> {
  const SecureChatNumberAccount()
      : super(name, path: 'secureChatNumberAccount');

  static const String name = 'SecureChatNumberAccount';
}

/// generated route for [_i18.BlockedUsers]
class BlockedUsers extends _i19.PageRouteInfo<BlockedUsersArgs> {
  BlockedUsers({_i28.Key? key})
      : super(name, path: 'blockedUsers', args: BlockedUsersArgs(key: key));

  static const String name = 'BlockedUsers';
}

class BlockedUsersArgs {
  const BlockedUsersArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'BlockedUsersArgs{key: $key}';
  }
}

/// generated route for [_i19.EmptyRouterPage]
class OnboardingRouter extends _i19.PageRouteInfo<void> {
  const OnboardingRouter({List<_i19.PageRouteInfo>? children})
      : super(name, path: 'onboarding', initialChildren: children);

  static const String name = 'OnboardingRouter';
}

/// generated route for [_i19.EmptyRouterPage]
class MessagesRouter extends _i19.PageRouteInfo<void> {
  const MessagesRouter({List<_i19.PageRouteInfo>? children})
      : super(name, path: 'messages', initialChildren: children);

  static const String name = 'MessagesRouter';
}

/// generated route for [_i19.EmptyRouterPage]
class VpnRouter extends _i19.PageRouteInfo<void> {
  const VpnRouter({List<_i19.PageRouteInfo>? children})
      : super(name, path: 'vpn', initialChildren: children);

  static const String name = 'VpnRouter';
}

/// generated route for [_i19.EmptyRouterPage]
class AccountRouter extends _i19.PageRouteInfo<void> {
  const AccountRouter({List<_i19.PageRouteInfo>? children})
      : super(name, path: 'account', initialChildren: children);

  static const String name = 'AccountRouter';
}

/// generated route for [_i19.EmptyRouterPage]
class DeveloperRoute extends _i19.PageRouteInfo<void> {
  const DeveloperRoute({List<_i19.PageRouteInfo>? children})
      : super(name, path: 'developer', initialChildren: children);

  static const String name = 'DeveloperRoute';
}

/// generated route for [_i20.Welcome]
class Welcome extends _i19.PageRouteInfo<void> {
  const Welcome() : super(name, path: 'welcome');

  static const String name = 'Welcome';
}

/// generated route for [_i21.SecureNumberRecovery]
class SecureNumberRecovery extends _i19.PageRouteInfo<void> {
  const SecureNumberRecovery() : super(name, path: 'secureNumberRecovery');

  static const String name = 'SecureNumberRecovery';
}

/// generated route for [_i22.SecureChatNumberMessaging]
class SecureChatNumberMessaging extends _i19.PageRouteInfo<void> {
  const SecureChatNumberMessaging()
      : super(name, path: 'secureChatNumberMessaging');

  static const String name = 'SecureChatNumberMessaging';
}

/// generated route for [_i23.Chats]
class ChatsRoute extends _i19.PageRouteInfo<void> {
  const ChatsRoute() : super(name, path: '');

  static const String name = 'ChatsRoute';
}

/// generated route for [_i24.VPNTab]
class Vpn extends _i19.PageRouteInfo<VpnArgs> {
  Vpn({_i28.Key? key}) : super(name, path: '', args: VpnArgs(key: key));

  static const String name = 'Vpn';
}

class VpnArgs {
  const VpnArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'VpnArgs{key: $key}';
  }
}

/// generated route for [_i25.AccountTab]
class Account extends _i19.PageRouteInfo<void> {
  const Account() : super(name, path: '');

  static const String name = 'Account';
}

/// generated route for [_i26.DeveloperSettingsTab]
class DeveloperSettings extends _i19.PageRouteInfo<DeveloperSettingsArgs> {
  DeveloperSettings({_i28.Key? key})
      : super(name, path: '', args: DeveloperSettingsArgs(key: key));

  static const String name = 'DeveloperSettings';
}

class DeveloperSettingsArgs {
  const DeveloperSettingsArgs({this.key});

  final _i28.Key? key;

  @override
  String toString() {
    return 'DeveloperSettingsArgs{key: $key}';
  }
}
