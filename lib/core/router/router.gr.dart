// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;
import 'package:lantern/messaging/conversation.dart' as _i5;
import 'package:lantern/messaging/introduce.dart' as _i9;
import 'package:lantern/messaging/introductions.dart' as _i10;
import 'package:lantern/messaging/messages.dart' as _i6;
import 'package:lantern/messaging/new_message.dart' as _i8;
import 'package:lantern/messaging/your_contact_info.dart' as _i7;
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart' as _i20;
import 'package:lantern/package_store.dart' as _i11;
import 'package:lantern/ui/home.dart' as _i3;
import 'package:lantern/ui/widgets/account/developer_settings.dart' as _i19;
import 'package:lantern/ui/widgets/account/device_linking/approve_device.dart'
    as _i18;
import 'package:lantern/ui/widgets/account/device_linking/authorize_device_for_pro.dart'
    as _i15;
import 'package:lantern/ui/widgets/account/device_linking/authorize_device_via_email.dart'
    as _i16;
import 'package:lantern/ui/widgets/account/device_linking/authorize_device_via_email_pin.dart'
    as _i17;
import 'package:lantern/ui/widgets/account/language.dart' as _i14;
import 'package:lantern/ui/widgets/account/pro_account.dart' as _i12;
import 'package:lantern/ui/widgets/account/settings.dart' as _i13;
import 'package:lantern/ui/widgets/full_screen_dialog.dart' as _i4;

class AppRouter extends _i1.RootStackRouter {
  AppRouter([_i2.GlobalKey<_i2.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    Home.name: (routeData) => _i1.AdaptivePage<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<HomeArgs>(orElse: () => const HomeArgs());
          return _i3.HomePage(key: args.key);
        }),
    FullScreenDialogPage.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<FullScreenDialogPageArgs>();
          return _i4.FullScreenDialog(widget: args.widget, key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    Conversation.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<ConversationArgs>();
          return _i5.Conversation(args.contactId);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    MessagesRouter.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        },
        opaque: true,
        barrierDismissible: false),
    VpnRouter.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        },
        opaque: true,
        barrierDismissible: false),
    AccountRouter.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        },
        opaque: true,
        barrierDismissible: false),
    DeveloperRoute.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        },
        opaque: true,
        barrierDismissible: false),
    MessagesRoute.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i6.Messages();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    ContactInfo.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i7.YourContactInfo();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    NewMessage.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i8.NewMessage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    Introduce.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i9.Introduce();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    Introductions.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i10.Introductions();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    Vpn.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<VpnArgs>(orElse: () => const VpnArgs());
          return _i11.VPNTab(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    Account.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i11.AccountTab();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    ProAccount.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args =
              data.argsAs<ProAccountArgs>(orElse: () => const ProAccountArgs());
          return _i12.ProAccount(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    Settings.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args =
              data.argsAs<SettingsArgs>(orElse: () => const SettingsArgs());
          return _i13.Settings(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    Language.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args =
              data.argsAs<LanguageArgs>(orElse: () => const LanguageArgs());
          return _i14.Language(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    AuthorizePro.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<AuthorizeProArgs>(
              orElse: () => const AuthorizeProArgs());
          return _i15.AuthorizeDeviceForPro(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    AuthorizeDeviceEmail.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<AuthorizeDeviceEmailArgs>(
              orElse: () => const AuthorizeDeviceEmailArgs());
          return _i16.AuthorizeDeviceViaEmail(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    AuthorizeDeviceEmailPin.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<AuthorizeDeviceEmailPinArgs>(
              orElse: () => const AuthorizeDeviceEmailPinArgs());
          return _i17.AuthorizeDeviceViaEmailPin(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    ApproveDevice.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<ApproveDeviceArgs>(
              orElse: () => const ApproveDeviceArgs());
          return _i18.ApproveDevice(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    DeveloperSettings.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<DeveloperSettingsArgs>(
              orElse: () => const DeveloperSettingsArgs());
          return _i19.DeveloperSettingsTab(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false)
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(Home.name, path: '/', children: [
          _i1.RouteConfig(MessagesRouter.name, path: 'messages', children: [
            _i1.RouteConfig(MessagesRoute.name, path: ''),
            _i1.RouteConfig(ContactInfo.name, path: 'contactInfo'),
            _i1.RouteConfig(NewMessage.name, path: 'newMessage'),
            _i1.RouteConfig(Introduce.name, path: 'introduce'),
            _i1.RouteConfig(Introductions.name, path: 'introductions')
          ]),
          _i1.RouteConfig(VpnRouter.name,
              path: 'vpn', children: [_i1.RouteConfig(Vpn.name, path: '')]),
          _i1.RouteConfig(AccountRouter.name, path: 'account', children: [
            _i1.RouteConfig(Account.name, path: ''),
            _i1.RouteConfig(ProAccount.name, path: 'proAccount'),
            _i1.RouteConfig(Settings.name, path: 'settings'),
            _i1.RouteConfig(Language.name, path: 'language'),
            _i1.RouteConfig(AuthorizePro.name, path: 'authorizePro'),
            _i1.RouteConfig(AuthorizeDeviceEmail.name,
                path: 'authorizeDeviceEmail'),
            _i1.RouteConfig(AuthorizeDeviceEmailPin.name,
                path: 'authorizeDeviceEmailPin'),
            _i1.RouteConfig(ApproveDevice.name, path: 'approveDevice')
          ]),
          _i1.RouteConfig(DeveloperRoute.name,
              path: 'developer',
              children: [_i1.RouteConfig(DeveloperSettings.name, path: '')])
        ]),
        _i1.RouteConfig(FullScreenDialogPage.name,
            path: 'fullScreenDialogPage'),
        _i1.RouteConfig(Conversation.name, path: 'conversation')
      ];
}

class Home extends _i1.PageRouteInfo<HomeArgs> {
  Home({_i11.Key? key, List<_i1.PageRouteInfo>? children})
      : super(name,
            path: '/', args: HomeArgs(key: key), initialChildren: children);

  static const String name = 'Home';
}

class HomeArgs {
  const HomeArgs({this.key});

  final _i11.Key? key;
}

class FullScreenDialogPage extends _i1.PageRouteInfo<FullScreenDialogPageArgs> {
  FullScreenDialogPage({required _i11.Widget widget, _i11.Key? key})
      : super(name,
            path: 'fullScreenDialogPage',
            args: FullScreenDialogPageArgs(widget: widget, key: key));

  static const String name = 'FullScreenDialogPage';
}

class FullScreenDialogPageArgs {
  const FullScreenDialogPageArgs({required this.widget, this.key});

  final _i11.Widget widget;

  final _i11.Key? key;
}

class Conversation extends _i1.PageRouteInfo<ConversationArgs> {
  Conversation({required _i20.ContactId contactId})
      : super(name,
            path: 'conversation', args: ConversationArgs(contactId: contactId));

  static const String name = 'Conversation';
}

class ConversationArgs {
  const ConversationArgs({required this.contactId});

  final _i20.ContactId contactId;
}

class MessagesRouter extends _i1.PageRouteInfo {
  const MessagesRouter({List<_i1.PageRouteInfo>? children})
      : super(name, path: 'messages', initialChildren: children);

  static const String name = 'MessagesRouter';
}

class VpnRouter extends _i1.PageRouteInfo {
  const VpnRouter({List<_i1.PageRouteInfo>? children})
      : super(name, path: 'vpn', initialChildren: children);

  static const String name = 'VpnRouter';
}

class AccountRouter extends _i1.PageRouteInfo {
  const AccountRouter({List<_i1.PageRouteInfo>? children})
      : super(name, path: 'account', initialChildren: children);

  static const String name = 'AccountRouter';
}

class DeveloperRoute extends _i1.PageRouteInfo {
  const DeveloperRoute({List<_i1.PageRouteInfo>? children})
      : super(name, path: 'developer', initialChildren: children);

  static const String name = 'DeveloperRoute';
}

class MessagesRoute extends _i1.PageRouteInfo {
  const MessagesRoute() : super(name, path: '');

  static const String name = 'MessagesRoute';
}

class ContactInfo extends _i1.PageRouteInfo {
  const ContactInfo() : super(name, path: 'contactInfo');

  static const String name = 'ContactInfo';
}

class NewMessage extends _i1.PageRouteInfo {
  const NewMessage() : super(name, path: 'newMessage');

  static const String name = 'NewMessage';
}

class Introduce extends _i1.PageRouteInfo {
  const Introduce() : super(name, path: 'introduce');

  static const String name = 'Introduce';
}

class Introductions extends _i1.PageRouteInfo {
  const Introductions() : super(name, path: 'introductions');

  static const String name = 'Introductions';
}

class Vpn extends _i1.PageRouteInfo<VpnArgs> {
  Vpn({_i11.Key? key}) : super(name, path: '', args: VpnArgs(key: key));

  static const String name = 'Vpn';
}

class VpnArgs {
  const VpnArgs({this.key});

  final _i11.Key? key;
}

class Account extends _i1.PageRouteInfo {
  const Account() : super(name, path: '');

  static const String name = 'Account';
}

class ProAccount extends _i1.PageRouteInfo<ProAccountArgs> {
  ProAccount({_i11.Key? key})
      : super(name, path: 'proAccount', args: ProAccountArgs(key: key));

  static const String name = 'ProAccount';
}

class ProAccountArgs {
  const ProAccountArgs({this.key});

  final _i11.Key? key;
}

class Settings extends _i1.PageRouteInfo<SettingsArgs> {
  Settings({_i11.Key? key})
      : super(name, path: 'settings', args: SettingsArgs(key: key));

  static const String name = 'Settings';
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i11.Key? key;
}

class Language extends _i1.PageRouteInfo<LanguageArgs> {
  Language({_i11.Key? key})
      : super(name, path: 'language', args: LanguageArgs(key: key));

  static const String name = 'Language';
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i11.Key? key;
}

class AuthorizePro extends _i1.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({_i11.Key? key})
      : super(name, path: 'authorizePro', args: AuthorizeProArgs(key: key));

  static const String name = 'AuthorizePro';
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i11.Key? key;
}

class AuthorizeDeviceEmail extends _i1.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({_i11.Key? key})
      : super(name,
            path: 'authorizeDeviceEmail',
            args: AuthorizeDeviceEmailArgs(key: key));

  static const String name = 'AuthorizeDeviceEmail';
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i11.Key? key;
}

class AuthorizeDeviceEmailPin
    extends _i1.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({_i11.Key? key})
      : super(name,
            path: 'authorizeDeviceEmailPin',
            args: AuthorizeDeviceEmailPinArgs(key: key));

  static const String name = 'AuthorizeDeviceEmailPin';
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i11.Key? key;
}

class ApproveDevice extends _i1.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({_i11.Key? key})
      : super(name, path: 'approveDevice', args: ApproveDeviceArgs(key: key));

  static const String name = 'ApproveDevice';
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i11.Key? key;
}

class DeveloperSettings extends _i1.PageRouteInfo<DeveloperSettingsArgs> {
  DeveloperSettings({_i11.Key? key})
      : super(name, path: '', args: DeveloperSettingsArgs(key: key));

  static const String name = 'DeveloperSettings';
}

class DeveloperSettingsArgs {
  const DeveloperSettingsArgs({this.key});

  final _i11.Key? key;
}
