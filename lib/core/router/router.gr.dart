// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i21;
import 'package:lantern/account/account_tab.dart' as _i12;
import 'package:lantern/account/developer_settings.dart' as _i20;
import 'package:lantern/account/device_linking/approve_device.dart' as _i19;
import 'package:lantern/account/device_linking/authorize_device_for_pro.dart'
    as _i16;
import 'package:lantern/account/device_linking/authorize_device_via_email.dart'
    as _i17;
import 'package:lantern/account/device_linking/authorize_device_via_email_pin.dart'
    as _i18;
import 'package:lantern/account/language.dart' as _i15;
import 'package:lantern/account/pro_account.dart' as _i13;
import 'package:lantern/account/settings.dart' as _i14;
import 'package:lantern/common/ui/full_screen_dialog.dart' as _i2;
import 'package:lantern/home.dart' as _i1;
import 'package:lantern/messaging/contacts/add_contact_number.dart' as _i6;
import 'package:lantern/messaging/contacts/contact_info.dart' as _i4;
import 'package:lantern/messaging/contacts/new_message.dart' as _i5;
import 'package:lantern/messaging/conversation/conversation.dart' as _i3;
import 'package:lantern/messaging/introductions/introduce.dart' as _i7;
import 'package:lantern/messaging/introductions/introductions.dart' as _i8;
import 'package:lantern/messaging/messages.dart' as _i10;
import 'package:lantern/messaging/messaging.dart' as _i22;
import 'package:lantern/vpn/vpn_tab.dart' as _i11;

class AppRouter extends _i9.RootStackRouter {
  AppRouter([_i21.GlobalKey<_i21.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    Home.name: (routeData) {
      final args = routeData.argsAs<HomeArgs>(orElse: () => const HomeArgs());
      return _i9.AdaptivePage<dynamic>(
          routeData: routeData, child: _i1.HomePage(key: args.key));
    },
    FullScreenDialogPage.name: (routeData) {
      final args = routeData.argsAs<FullScreenDialogPageArgs>();
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i2.FullScreenDialog(widget: args.widget, key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Conversation.name: (routeData) {
      final args = routeData.argsAs<ConversationArgs>();
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i3.Conversation(
              contactId: args.contactId,
              initialScrollIndex: args.initialScrollIndex),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ContactInfo.name: (routeData) {
      final args = routeData.argsAs<ContactInfoArgs>();
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i4.ContactInfo(model: args.model, contact: args.contact),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    NewMessage.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i5.NewMessage(),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AddViaChatNumber.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i6.AddViaChatNumber(),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introduce.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i7.Introduce(),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Introductions.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i8.Introductions(),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    MessagesRouter.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: const _i9.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    VpnRouter.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: const _i9.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    AccountRouter.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: const _i9.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    DeveloperRoute.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: const _i9.EmptyRouterPage(),
          opaque: true,
          barrierDismissible: false);
    },
    MessagesRoute.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i10.Messages(),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Vpn.name: (routeData) {
      final args = routeData.argsAs<VpnArgs>(orElse: () => const VpnArgs());
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i11.VPNTab(key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Account.name: (routeData) {
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i12.AccountTab(),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ProAccount.name: (routeData) {
      final args = routeData.argsAs<ProAccountArgs>(
          orElse: () => const ProAccountArgs());
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i13.ProAccount(key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Settings.name: (routeData) {
      final args =
          routeData.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i14.Settings(key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    Language.name: (routeData) {
      final args =
          routeData.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i15.Language(key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizePro.name: (routeData) {
      final args = routeData.argsAs<AuthorizeProArgs>(
          orElse: () => const AuthorizeProArgs());
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i16.AuthorizeDeviceForPro(key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmail.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailArgs>(
          orElse: () => const AuthorizeDeviceEmailArgs());
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i17.AuthorizeDeviceViaEmail(key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    AuthorizeDeviceEmailPin.name: (routeData) {
      final args = routeData.argsAs<AuthorizeDeviceEmailPinArgs>(
          orElse: () => const AuthorizeDeviceEmailPinArgs());
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i18.AuthorizeDeviceViaEmailPin(key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    ApproveDevice.name: (routeData) {
      final args = routeData.argsAs<ApproveDeviceArgs>(
          orElse: () => const ApproveDeviceArgs());
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i19.ApproveDevice(key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    },
    DeveloperSettings.name: (routeData) {
      final args = routeData.argsAs<DeveloperSettingsArgs>(
          orElse: () => const DeveloperSettingsArgs());
      return _i9.CustomPage<void>(
          routeData: routeData,
          child: _i20.DeveloperSettingsTab(key: args.key),
          transitionsBuilder: _i9.TransitionsBuilders.fadeIn,
          durationInMilliseconds: 200,
          reverseDurationInMilliseconds: 200,
          opaque: true,
          barrierDismissible: false);
    }
  };

  @override
  List<_i9.RouteConfig> get routes => [
        _i9.RouteConfig(Home.name, path: '/', children: [
          _i9.RouteConfig(MessagesRouter.name,
              path: 'messages',
              children: [_i9.RouteConfig(MessagesRoute.name, path: '')]),
          _i9.RouteConfig(VpnRouter.name,
              path: 'vpn', children: [_i9.RouteConfig(Vpn.name, path: '')]),
          _i9.RouteConfig(AccountRouter.name, path: 'account', children: [
            _i9.RouteConfig(Account.name, path: ''),
            _i9.RouteConfig(ProAccount.name, path: 'proAccount'),
            _i9.RouteConfig(Settings.name, path: 'settings'),
            _i9.RouteConfig(Language.name, path: 'language'),
            _i9.RouteConfig(AuthorizePro.name, path: 'authorizePro'),
            _i9.RouteConfig(AuthorizeDeviceEmail.name,
                path: 'authorizeDeviceEmail'),
            _i9.RouteConfig(AuthorizeDeviceEmailPin.name,
                path: 'authorizeDeviceEmailPin'),
            _i9.RouteConfig(ApproveDevice.name, path: 'approveDevice')
          ]),
          _i9.RouteConfig(DeveloperRoute.name,
              path: 'developer',
              children: [_i9.RouteConfig(DeveloperSettings.name, path: '')])
        ]),
        _i9.RouteConfig(FullScreenDialogPage.name,
            path: 'fullScreenDialogPage'),
        _i9.RouteConfig(Conversation.name, path: 'conversation'),
        _i9.RouteConfig(ContactInfo.name, path: 'contactInfo'),
        _i9.RouteConfig(NewMessage.name, path: 'newMessage'),
        _i9.RouteConfig(AddViaChatNumber.name, path: 'addViaChatNumber'),
        _i9.RouteConfig(Introduce.name, path: 'introduce'),
        _i9.RouteConfig(Introductions.name, path: 'introductions')
      ];
}

/// generated route for [_i1.HomePage]
class Home extends _i9.PageRouteInfo<HomeArgs> {
  Home({_i22.Key? key, List<_i9.PageRouteInfo>? children})
      : super(name,
            path: '/', args: HomeArgs(key: key), initialChildren: children);

  static const String name = 'Home';
}

class HomeArgs {
  const HomeArgs({this.key});

  final _i22.Key? key;
}

/// generated route for [_i2.FullScreenDialog]
class FullScreenDialogPage extends _i9.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({required _i22.Widget widget, _i22.Key? key})
      : super(name,
            path: 'fullScreenDialogPage',
            args: FullScreenDialogPageArgs(widget: widget, key: key));

  static const String name = 'FullScreenDialogPage';
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({required this.widget, this.key});

  final _i22.Widget widget;

  final _i22.Key? key;
}

/// generated route for [_i3.Conversation]
class Conversation extends _i9.PageRouteInfo<ConversationArgs> {
  Conversation({required _i22.ContactId contactId, int? initialScrollIndex})
      : super(name,
            path: 'conversation',
            args: ConversationArgs(
                contactId: contactId, initialScrollIndex: initialScrollIndex));

  static const String name = 'Conversation';
}

class ConversationArgs {
  const ConversationArgs({required this.contactId, this.initialScrollIndex});

  final _i22.ContactId contactId;

  final int? initialScrollIndex;
}

/// generated route for [_i4.ContactInfo]
class ContactInfo extends _i9.PageRouteInfo<ContactInfoArgs> {
  ContactInfo(
      {required _i22.MessagingModel model, required _i22.Contact contact})
      : super(name,
            path: 'contactInfo',
            args: ContactInfoArgs(model: model, contact: contact));

  static const String name = 'ContactInfo';
}

class ContactInfoArgs {
  const ContactInfoArgs({required this.model, required this.contact});

  final _i22.MessagingModel model;

  final _i22.Contact contact;
}

/// generated route for [_i5.NewMessage]
class NewMessage extends _i9.PageRouteInfo<void> {
  const NewMessage() : super(name, path: 'newMessage');

  static const String name = 'NewMessage';
}

/// generated route for [_i6.AddViaChatNumber]
class AddViaChatNumber extends _i9.PageRouteInfo<void> {
  const AddViaChatNumber() : super(name, path: 'addViaChatNumber');

  static const String name = 'AddViaChatNumber';
}

/// generated route for [_i7.Introduce]
class Introduce extends _i9.PageRouteInfo<void> {
  const Introduce() : super(name, path: 'introduce');

  static const String name = 'Introduce';
}

/// generated route for [_i8.Introductions]
class Introductions extends _i9.PageRouteInfo<void> {
  const Introductions() : super(name, path: 'introductions');

  static const String name = 'Introductions';
}

/// generated route for [_i9.EmptyRouterPage]
class MessagesRouter extends _i9.PageRouteInfo<void> {
  const MessagesRouter({List<_i9.PageRouteInfo>? children})
      : super(name, path: 'messages', initialChildren: children);

  static const String name = 'MessagesRouter';
}

/// generated route for [_i9.EmptyRouterPage]
class VpnRouter extends _i9.PageRouteInfo<void> {
  const VpnRouter({List<_i9.PageRouteInfo>? children})
      : super(name, path: 'vpn', initialChildren: children);

  static const String name = 'VpnRouter';
}

/// generated route for [_i9.EmptyRouterPage]
class AccountRouter extends _i9.PageRouteInfo<void> {
  const AccountRouter({List<_i9.PageRouteInfo>? children})
      : super(name, path: 'account', initialChildren: children);

  static const String name = 'AccountRouter';
}

/// generated route for [_i9.EmptyRouterPage]
class DeveloperRoute extends _i9.PageRouteInfo<void> {
  const DeveloperRoute({List<_i9.PageRouteInfo>? children})
      : super(name, path: 'developer', initialChildren: children);

  static const String name = 'DeveloperRoute';
}

/// generated route for [_i10.Messages]
class MessagesRoute extends _i9.PageRouteInfo<void> {
  const MessagesRoute() : super(name, path: '');

  static const String name = 'MessagesRoute';
}

/// generated route for [_i11.VPNTab]
class Vpn extends _i9.PageRouteInfo<VpnArgs> {
  Vpn({_i22.Key? key}) : super(name, path: '', args: VpnArgs(key: key));

  static const String name = 'Vpn';
}

class VpnArgs {
  const VpnArgs({this.key});

  final _i22.Key? key;
}

/// generated route for [_i12.AccountTab]
class Account extends _i9.PageRouteInfo<void> {
  const Account() : super(name, path: '');

  static const String name = 'Account';
}

/// generated route for [_i13.ProAccount]
class ProAccount extends _i9.PageRouteInfo<ProAccountArgs> {
  ProAccount({_i22.Key? key})
      : super(name, path: 'proAccount', args: ProAccountArgs(key: key));

  static const String name = 'ProAccount';
}

class ProAccountArgs {
  const ProAccountArgs({this.key});

  final _i22.Key? key;
}

/// generated route for [_i14.Settings]
class Settings extends _i9.PageRouteInfo<SettingsArgs> {
  Settings({_i22.Key? key})
      : super(name, path: 'settings', args: SettingsArgs(key: key));

  static const String name = 'Settings';
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i22.Key? key;
}

/// generated route for [_i15.Language]
class Language extends _i9.PageRouteInfo<LanguageArgs> {
  Language({_i22.Key? key})
      : super(name, path: 'language', args: LanguageArgs(key: key));

  static const String name = 'Language';
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i22.Key? key;
}

/// generated route for [_i16.AuthorizeDeviceForPro]
class AuthorizePro extends _i9.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({_i22.Key? key})
      : super(name, path: 'authorizePro', args: AuthorizeProArgs(key: key));

  static const String name = 'AuthorizePro';
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i22.Key? key;
}

/// generated route for [_i17.AuthorizeDeviceViaEmail]
class AuthorizeDeviceEmail extends _i9.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({_i22.Key? key})
      : super(name,
            path: 'authorizeDeviceEmail',
            args: AuthorizeDeviceEmailArgs(key: key));

  static const String name = 'AuthorizeDeviceEmail';
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i22.Key? key;
}

/// generated route for [_i18.AuthorizeDeviceViaEmailPin]
class AuthorizeDeviceEmailPin
    extends _i9.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({_i22.Key? key})
      : super(name,
            path: 'authorizeDeviceEmailPin',
            args: AuthorizeDeviceEmailPinArgs(key: key));

  static const String name = 'AuthorizeDeviceEmailPin';
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i22.Key? key;
}

/// generated route for [_i19.ApproveDevice]
class ApproveDevice extends _i9.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({_i22.Key? key})
      : super(name, path: 'approveDevice', args: ApproveDeviceArgs(key: key));

  static const String name = 'ApproveDevice';
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i22.Key? key;
}

/// generated route for [_i20.DeveloperSettingsTab]
class DeveloperSettings extends _i9.PageRouteInfo<DeveloperSettingsArgs> {
  DeveloperSettings({_i22.Key? key})
      : super(name, path: '', args: DeveloperSettingsArgs(key: key));

  static const String name = 'DeveloperSettings';
}

class DeveloperSettingsArgs {
  const DeveloperSettingsArgs({this.key});

  final _i22.Key? key;
}
