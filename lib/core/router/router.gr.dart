// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i21;
import 'package:flutter/material.dart' as _i22;
import 'package:lantern/account/account_management.dart' as _i11;
import 'package:lantern/account/blocked_users.dart' as _i20;
import 'package:lantern/account/device_linking/approve_device.dart' as _i17;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i14;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i15;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i16;
import 'package:lantern/account/language.dart' as _i13;
import 'package:lantern/account/recovery_key.dart' as _i18;
import 'package:lantern/account/secure_chat_number_account.dart' as _i19;
import 'package:lantern/account/settings.dart' as _i12;
import 'package:lantern/common/common.dart' as _i23;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i4;
import 'package:lantern/home.dart' as _i1;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i8;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i6;
import 'package:lantern/messaging/contacts/new_chat.dart' as _i7;
import 'package:lantern/messaging/conversation/conversation.dart' as _i5;
import 'package:lantern/messaging/introductions/introduce.dart' as _i9;
import 'package:lantern/messaging/introductions/introductions.dart' as _i10;
import 'package:lantern/messaging/onboarding/secure_chat_number_messaging.dart'
    as _i3;
import 'package:lantern/messaging/onboarding/secure_chat_number_recovery.dart'
    as _i2;
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart' as _i24;

class AppRouter extends _i21.RootStackRouter {
  AppRouter([_i22.GlobalKey<_i22.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i21.PageFactory> pagesMap = {
    Home.name: (routeData) {
      final args = routeData.argsAs<HomeArgs>(orElse: () => const HomeArgs());
      return _i21.AdaptivePage<dynamic>(
          routeData: routeData, child: _i1.HomePage(key: args.key));
    },
    SecureNumberRecovery.name: (routeData) {
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i2.SecureNumberRecovery(),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    SecureChatNumberMessaging.name: (routeData) {
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i3.SecureChatNumberMessaging(),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i4.FullScreenDialog(widget: args.widget, key: args.key),
          transitionsBuilder: _i21.TransitionsBuilders.slideBottom,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i5.Conversation(
              contactId: args.contactId,
              initialScrollIndex: args.initialScrollIndex,
              showContactEditingDialog: args.showContactEditingDialog),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i6.ContactInfo(contact: args.contact),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    NewChat.name: (routeData) {
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i7.NewChat(),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AddViaChatNumber.name: (routeData) {
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i8.AddViaChatNumber(),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introduce.name: (routeData) {
      final args = routeData.argsAs<IntroduceArgs>();
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i9.Introduce(
              singleIntro: args.singleIntro,
              contactToIntro: args.contactToIntro),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introductions.name: (routeData) {
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i10.Introductions(),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AccountManagement.name: (routeData) {
      final args = routeData.argsAs<AccountManagementArgs>();
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i11.AccountManagement(key: args.key, isPro: args.isPro),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i12.Settings(key: args.key),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i13.Language(key: args.key),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizePro.name: (routeData) {
      final args = routeData.argsAs<AuthorizeProArgs>(
          orElse: () => const AuthorizeProArgs());
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i14.AuthorizeDeviceForPro(key: args.key),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i15.AuthorizeDeviceViaEmail(key: args.key),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>(
          orElse: () => const AuthorizeDeviceEmailPinArgs());
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i16.AuthorizeDeviceViaEmailPin(key: args.key),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i17.ApproveDevice(key: args.key),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    RecoveryKey.name: (routeData) {
      final args = routeData.argsAs<RecoveryKeyArgs>(
          orElse: () => const RecoveryKeyArgs());
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i18.RecoveryKey(key: args.key),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    SecureChatNumberAccount.name: (routeData) {
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i19.SecureChatNumberAccount(),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    BlockedUsers.name: (routeData) {
      final args = routeData.argsAs<BlockedUsersArgs>(
          orElse: () => const BlockedUsersArgs());
      return _i21.CustomPage<void>(
          routeData: routeData,
          child: _i20.BlockedUsers(key: args.key),
          transitionsBuilder: _i21.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    }
  };

  @override
  List<_i21.RouteConfig> get routes => [
        _i21.RouteConfig(Home.name, path: '/'),
        _i21.RouteConfig(SecureNumberRecovery.name,
            path: 'secureNumberRecovery'),
        _i21.RouteConfig(SecureChatNumberMessaging.name,
            path: 'secureChatNumberMessaging'),
        _i21.RouteConfig(FullScreenDialogPage.name,
            path: 'fullScreenDialogPage'),
        _i21.RouteConfig(Conversation.name, path: 'conversation'),
        _i21.RouteConfig(ContactInfo.name, path: 'contactInfo'),
        _i21.RouteConfig(NewChat.name, path: 'newChat'),
        _i21.RouteConfig(AddViaChatNumber.name, path: 'addViaChatNumber'),
        _i21.RouteConfig(Introduce.name, path: 'introduce'),
        _i21.RouteConfig(Introductions.name, path: 'introductions'),
        _i21.RouteConfig(AccountManagement.name, path: 'accountManagement'),
        _i21.RouteConfig(Settings.name, path: 'settings'),
        _i21.RouteConfig(Language.name, path: 'language'),
        _i21.RouteConfig(AuthorizePro.name, path: 'authorizePro'),
        _i21.RouteConfig(AuthorizeDeviceEmail.name,
            path: 'authorizeDeviceEmail'),
        _i21.RouteConfig(AuthorizeDeviceEmailPin.name,
            path: 'authorizeDeviceEmailPin'),
        _i21.RouteConfig(ApproveDevice.name, path: 'approveDevice'),
        _i21.RouteConfig(RecoveryKey.name, path: 'recoveryKey'),
        _i21.RouteConfig(SecureChatNumberAccount.name,
            path: 'secureChatNumberAccount'),
        _i21.RouteConfig(BlockedUsers.name, path: 'blockedUsers')
      ];
}

/// generated route for [_i1.HomePage]
class Home extends _i21.PageRouteInfo<HomeArgs> {
  Home({_i23.Key? key}) : super(name, path: '/', args: HomeArgs(key: key));

  static const String name = 'Home';
}

class HomeArgs {
  const HomeArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'HomeArgs{key: $key}';
  }
}

/// generated route for [_i2.SecureNumberRecovery]
class SecureNumberRecovery extends _i21.PageRouteInfo<void> {
  const SecureNumberRecovery() : super(name, path: 'secureNumberRecovery');

  static const String name = 'SecureNumberRecovery';
}

/// generated route for [_i3.SecureChatNumberMessaging]
class SecureChatNumberMessaging extends _i21.PageRouteInfo<void> {
  const SecureChatNumberMessaging()
      : super(name, path: 'secureChatNumberMessaging');

  static const String name = 'SecureChatNumberMessaging';
}

/// generated route for [_i4.FullScreenDialog]
class FullScreenDialogPage
    extends _i21.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({required _i23.Widget widget, _i23.Key? key})
      : super(name,
            path: 'fullScreenDialogPage',
            args: FullScreenDialogPageArgs(widget: widget, key: key));

  static const String name = 'FullScreenDialogPage';
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({required this.widget, this.key});

  final _i23.Widget widget;

  final _i23.Key? key;

  @override
  String toString() {
    return 'FullScreenDialogPageArgs{widget: $widget, key: $key}';
  }
}

/// generated route for [_i5.Conversation]
class Conversation extends _i21.PageRouteInfo<ConversationArgs> {
  Conversation(
      {required _i24.ContactId contactId,
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

  final _i24.ContactId contactId;

  final int? initialScrollIndex;

  final bool? showContactEditingDialog;

  @override
  String toString() {
    return 'ConversationArgs{contactId: $contactId, initialScrollIndex: $initialScrollIndex, showContactEditingDialog: $showContactEditingDialog}';
  }
}

/// generated route for [_i6.ContactInfo]
class ContactInfo extends _i21.PageRouteInfo<ContactInfoArgs> {
  ContactInfo({required _i24.Contact contact})
      : super(name,
            path: 'contactInfo', args: ContactInfoArgs(contact: contact));

  static const String name = 'ContactInfo';
}

class ContactInfoArgs {
  const ContactInfoArgs({required this.contact});

  final _i24.Contact contact;

  @override
  String toString() {
    return 'ContactInfoArgs{contact: $contact}';
  }
}

/// generated route for [_i7.NewChat]
class NewChat extends _i21.PageRouteInfo<void> {
  const NewChat() : super(name, path: 'newChat');

  static const String name = 'NewChat';
}

/// generated route for [_i8.AddViaChatNumber]
class AddViaChatNumber extends _i21.PageRouteInfo<void> {
  const AddViaChatNumber() : super(name, path: 'addViaChatNumber');

  static const String name = 'AddViaChatNumber';
}

/// generated route for [_i9.Introduce]
class Introduce extends _i21.PageRouteInfo<IntroduceArgs> {
  Introduce({required bool singleIntro, _i24.Contact? contactToIntro})
      : super(name,
            path: 'introduce',
            args: IntroduceArgs(
                singleIntro: singleIntro, contactToIntro: contactToIntro));

  static const String name = 'Introduce';
}

class IntroduceArgs {
  const IntroduceArgs({required this.singleIntro, this.contactToIntro});

  final bool singleIntro;

  final _i24.Contact? contactToIntro;

  @override
  String toString() {
    return 'IntroduceArgs{singleIntro: $singleIntro, contactToIntro: $contactToIntro}';
  }
}

/// generated route for [_i10.Introductions]
class Introductions extends _i21.PageRouteInfo<void> {
  const Introductions() : super(name, path: 'introductions');

  static const String name = 'Introductions';
}

/// generated route for [_i11.AccountManagement]
class AccountManagement extends _i21.PageRouteInfo<AccountManagementArgs> {
  AccountManagement({_i23.Key? key, required bool isPro})
      : super(name,
            path: 'accountManagement',
            args: AccountManagementArgs(key: key, isPro: isPro));

  static const String name = 'AccountManagement';
}

class AccountManagementArgs {
  const AccountManagementArgs({this.key, required this.isPro});

  final _i23.Key? key;

  final bool isPro;

  @override
  String toString() {
    return 'AccountManagementArgs{key: $key, isPro: $isPro}';
  }
}

/// generated route for [_i12.Settings]
class Settings extends _i21.PageRouteInfo<SettingsArgs> {
  Settings({_i23.Key? key})
      : super(name, path: 'settings', args: SettingsArgs(key: key));

  static const String name = 'Settings';
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'SettingsArgs{key: $key}';
  }
}

/// generated route for [_i13.Language]
class Language extends _i21.PageRouteInfo<LanguageArgs> {
  Language({_i23.Key? key})
      : super(name, path: 'language', args: LanguageArgs(key: key));

  static const String name = 'Language';
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'LanguageArgs{key: $key}';
  }
}

/// generated route for [_i14.AuthorizeDeviceForPro]
class AuthorizePro extends _i21.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({_i23.Key? key})
      : super(name, path: 'authorizePro', args: AuthorizeProArgs(key: key));

  static const String name = 'AuthorizePro';
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'AuthorizeProArgs{key: $key}';
  }
}

/// generated route for [_i15.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail
    extends _i21.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({_i23.Key? key})
      : super(name,
            path: 'authorizeDeviceEmail',
            args: AuthorizeDeviceEmailArgs(key: key));

  static const String name = 'AuthorizeDeviceEmail';
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailArgs{key: $key}';
  }
}

/// generated route for [_i16.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i21.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({_i23.Key? key})
      : super(name,
            path: 'authorizeDeviceEmailPin',
            args: AuthorizeDeviceEmailPinArgs(key: key));

  static const String name = 'AuthorizeDeviceEmailPin';
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'AuthorizeDeviceEmailPinArgs{key: $key}';
  }
}

/// generated route for [_i17.ApproveDevice]
class ApproveDevice extends _i21.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({_i23.Key? key})
      : super(name, path: 'approveDevice', args: ApproveDeviceArgs(key: key));

  static const String name = 'ApproveDevice';
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'ApproveDeviceArgs{key: $key}';
  }
}

/// generated route for [_i18.RecoveryKey]
class RecoveryKey extends _i21.PageRouteInfo<RecoveryKeyArgs> {
  RecoveryKey({_i23.Key? key})
      : super(name, path: 'recoveryKey', args: RecoveryKeyArgs(key: key));

  static const String name = 'RecoveryKey';
}

class RecoveryKeyArgs {
  const RecoveryKeyArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'RecoveryKeyArgs{key: $key}';
  }
}

/// generated route for [_i19.SecureChatNumberAccount]
class SecureChatNumberAccount extends _i21.PageRouteInfo<void> {
  const SecureChatNumberAccount()
      : super(name, path: 'secureChatNumberAccount');

  static const String name = 'SecureChatNumberAccount';
}

/// generated route for [_i20.BlockedUsers]
class BlockedUsers extends _i21.PageRouteInfo<BlockedUsersArgs> {
  BlockedUsers({_i23.Key? key})
      : super(name, path: 'blockedUsers', args: BlockedUsersArgs(key: key));

  static const String name = 'BlockedUsers';
}

class BlockedUsersArgs {
  const BlockedUsersArgs({this.key});

  final _i23.Key? key;

  @override
  String toString() {
    return 'BlockedUsersArgs{key: $key}';
  }
}
