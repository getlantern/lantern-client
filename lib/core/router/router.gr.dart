// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;
import 'package:lantern/messaging/add_contact_QR.dart' as _i7;
import 'package:lantern/messaging/add_contact_username.dart' as _i8;
import 'package:lantern/messaging/contact_options.dart' as _i11;
import 'package:lantern/messaging/contacts.dart' as _i10;
import 'package:lantern/messaging/conversation.dart' as _i9;
import 'package:lantern/messaging/conversations.dart' as _i4;
import 'package:lantern/messaging/new_message.dart' as _i6;
import 'package:lantern/messaging/your_contact_info.dart' as _i5;
import 'package:lantern/model/model.dart' as _i22;
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart' as _i21;
import 'package:lantern/package_store.dart' as _i12;
import 'package:lantern/ui/home.dart' as _i3;
import 'package:lantern/ui/widgets/account/developer_settings.dart' as _i20;
import 'package:lantern/ui/widgets/account/device_linking/approve_device.dart'
    as _i19;
import 'package:lantern/ui/widgets/account/device_linking/authorize_device_for_pro.dart'
    as _i16;
import 'package:lantern/ui/widgets/account/device_linking/authorize_device_via_email.dart'
    as _i17;
import 'package:lantern/ui/widgets/account/device_linking/authorize_device_via_email_pin.dart'
    as _i18;
import 'package:lantern/ui/widgets/account/language.dart' as _i15;
import 'package:lantern/ui/widgets/account/pro_account.dart' as _i13;
import 'package:lantern/ui/widgets/account/settings.dart' as _i14;

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
    ConversationsRoute.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i4.Conversations();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    ContactInfo.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i5.YourContactInfo();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    NewMessage.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i6.NewMessage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    AddQR.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i7.AddViaQR();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    AddUsername.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i8.AddViaUsername();
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
          return _i9.Conversation(args.contact);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    Contacts.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i10.Contacts();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    ContactOptions.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<ContactOptionsArgs>();
          return _i11.ContactOptions(args.contact);
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
          return _i12.VPNTab(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    Account.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i12.AccountTab();
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
          return _i13.ProAccount(key: args.key);
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
          return _i14.Settings(key: args.key);
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
          return _i15.Language(key: args.key);
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
          return _i16.AuthorizeDeviceForPro(key: args.key);
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
          return _i17.AuthorizeDeviceViaEmail(key: args.key);
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
          return _i18.AuthorizeDeviceViaEmailPin(key: args.key);
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
          return _i19.ApproveDevice(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 450,
        reverseDurationInMilliseconds: 450,
        opaque: true,
        barrierDismissible: false),
    DeveloperSetting.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<DeveloperSettingArgs>(
              orElse: () => const DeveloperSettingArgs());
          return _i20.DeveloperSettingsTab(key: args.key);
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
            _i1.RouteConfig(ConversationsRoute.name, path: ''),
            _i1.RouteConfig(ContactInfo.name, path: 'contactInfo'),
            _i1.RouteConfig(NewMessage.name, path: 'newMessage'),
            _i1.RouteConfig(AddQR.name, path: 'addQR'),
            _i1.RouteConfig(AddUsername.name, path: 'addUsername'),
            _i1.RouteConfig(Conversation.name, path: 'conversation'),
            _i1.RouteConfig(Contacts.name, path: 'contacts'),
            _i1.RouteConfig(ContactOptions.name, path: 'contactOptions')
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
            _i1.RouteConfig(ApproveDevice.name, path: 'approveDevice'),
            _i1.RouteConfig(Contacts.name, path: 'contacts')
          ]),
          _i1.RouteConfig(DeveloperRoute.name,
              path: 'developer',
              children: [_i1.RouteConfig(DeveloperSetting.name, path: '')])
        ])
      ];
}

class Home extends _i1.PageRouteInfo<HomeArgs> {
  Home({_i12.Key? key, List<_i1.PageRouteInfo>? children})
      : super(name,
            path: '/', args: HomeArgs(key: key), initialChildren: children);

  static const String name = 'Home';
}

class HomeArgs {
  const HomeArgs({this.key});

  final _i12.Key? key;
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

class ConversationsRoute extends _i1.PageRouteInfo {
  const ConversationsRoute() : super(name, path: '');

  static const String name = 'ConversationsRoute';
}

class ContactInfo extends _i1.PageRouteInfo {
  const ContactInfo() : super(name, path: 'contactInfo');

  static const String name = 'ContactInfo';
}

class NewMessage extends _i1.PageRouteInfo {
  const NewMessage() : super(name, path: 'newMessage');

  static const String name = 'NewMessage';
}

class AddQR extends _i1.PageRouteInfo {
  const AddQR() : super(name, path: 'addQR');

  static const String name = 'AddQR';
}

class AddUsername extends _i1.PageRouteInfo {
  const AddUsername() : super(name, path: 'addUsername');

  static const String name = 'AddUsername';
}

class Conversation extends _i1.PageRouteInfo<ConversationArgs> {
  Conversation({required _i21.Contact contact})
      : super(name,
            path: 'conversation', args: ConversationArgs(contact: contact));

  static const String name = 'Conversation';
}

class ConversationArgs {
  const ConversationArgs({required this.contact});

  final _i21.Contact contact;
}

class Contacts extends _i1.PageRouteInfo {
  const Contacts() : super(name, path: 'contacts');

  static const String name = 'Contacts';
}

class ContactOptions extends _i1.PageRouteInfo<ContactOptionsArgs> {
  ContactOptions({required _i22.PathAndValue<_i21.Contact> contact})
      : super(name,
            path: 'contactOptions', args: ContactOptionsArgs(contact: contact));

  static const String name = 'ContactOptions';
}

class ContactOptionsArgs {
  const ContactOptionsArgs({required this.contact});

  final _i22.PathAndValue<_i21.Contact> contact;
}

class Vpn extends _i1.PageRouteInfo<VpnArgs> {
  Vpn({_i12.Key? key}) : super(name, path: '', args: VpnArgs(key: key));

  static const String name = 'Vpn';
}

class VpnArgs {
  const VpnArgs({this.key});

  final _i12.Key? key;
}

class Account extends _i1.PageRouteInfo {
  const Account() : super(name, path: '');

  static const String name = 'Account';
}

class ProAccount extends _i1.PageRouteInfo<ProAccountArgs> {
  ProAccount({_i12.Key? key})
      : super(name, path: 'proAccount', args: ProAccountArgs(key: key));

  static const String name = 'ProAccount';
}

class ProAccountArgs {
  const ProAccountArgs({this.key});

  final _i12.Key? key;
}

class Settings extends _i1.PageRouteInfo<SettingsArgs> {
  Settings({_i12.Key? key})
      : super(name, path: 'settings', args: SettingsArgs(key: key));

  static const String name = 'Settings';
}

class SettingsArgs {
  const SettingsArgs({this.key});

  final _i12.Key? key;
}

class Language extends _i1.PageRouteInfo<LanguageArgs> {
  Language({_i12.Key? key})
      : super(name, path: 'language', args: LanguageArgs(key: key));

  static const String name = 'Language';
}

class LanguageArgs {
  const LanguageArgs({this.key});

  final _i12.Key? key;
}

class AuthorizePro extends _i1.PageRouteInfo<AuthorizeProArgs> {
  AuthorizePro({_i12.Key? key})
      : super(name, path: 'authorizePro', args: AuthorizeProArgs(key: key));

  static const String name = 'AuthorizePro';
}

class AuthorizeProArgs {
  const AuthorizeProArgs({this.key});

  final _i12.Key? key;
}

class AuthorizeDeviceEmail extends _i1.PageRouteInfo<AuthorizeDeviceEmailArgs> {
  AuthorizeDeviceEmail({_i12.Key? key})
      : super(name,
            path: 'authorizeDeviceEmail',
            args: AuthorizeDeviceEmailArgs(key: key));

  static const String name = 'AuthorizeDeviceEmail';
}

class AuthorizeDeviceEmailArgs {
  const AuthorizeDeviceEmailArgs({this.key});

  final _i12.Key? key;
}

class AuthorizeDeviceEmailPin
    extends _i1.PageRouteInfo<AuthorizeDeviceEmailPinArgs> {
  AuthorizeDeviceEmailPin({_i12.Key? key})
      : super(name,
            path: 'authorizeDeviceEmailPin',
            args: AuthorizeDeviceEmailPinArgs(key: key));

  static const String name = 'AuthorizeDeviceEmailPin';
}

class AuthorizeDeviceEmailPinArgs {
  const AuthorizeDeviceEmailPinArgs({this.key});

  final _i12.Key? key;
}

class ApproveDevice extends _i1.PageRouteInfo<ApproveDeviceArgs> {
  ApproveDevice({_i12.Key? key})
      : super(name, path: 'approveDevice', args: ApproveDeviceArgs(key: key));

  static const String name = 'ApproveDevice';
}

class ApproveDeviceArgs {
  const ApproveDeviceArgs({this.key});

  final _i12.Key? key;
}

class DeveloperSetting extends _i1.PageRouteInfo<DeveloperSettingArgs> {
  DeveloperSetting({_i12.Key? key})
      : super(name, path: '', args: DeveloperSettingArgs(key: key));

  static const String name = 'DeveloperSetting';
}

class DeveloperSettingArgs {
  const DeveloperSettingArgs({this.key});

  final _i12.Key? key;
}
