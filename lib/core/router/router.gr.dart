// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;
import 'package:lantern/core/router/router_observer.dart' as _i3;
import 'package:lantern/messaging/add_contact_QR.dart' as _i9;
import 'package:lantern/messaging/add_contact_username.dart' as _i10;
import 'package:lantern/messaging/conversation.dart' as _i11;
import 'package:lantern/messaging/conversations.dart' as _i6;
import 'package:lantern/messaging/new_message.dart' as _i8;
import 'package:lantern/messaging/your_contact_info.dart' as _i7;
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart' as _i13;
import 'package:lantern/package_store.dart' as _i12;
import 'package:lantern/ui/index.dart' as _i4;
import 'package:lantern/ui/widgets/account/developer_settings.dart' as _i5;

class AppRouter extends _i1.RootStackRouter {
  AppRouter(
      {_i2.GlobalKey<_i2.NavigatorState>? navigatorKey,
      required this.routerObserver})
      : super(navigatorKey);

  final _i3.RouterObserver routerObserver;

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    Home.name: (routeData) => _i1.AdaptivePage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<HomeArgs>(orElse: () => const HomeArgs());
          return _i4.HomePage(key: args.key);
        }),
    MessagesRouter.name: (routeData) => _i1.AdaptivePage<void>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    Vpn.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<VpnArgs>(orElse: () => const VpnArgs());
          return _i4.VPNTab(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    Account.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i4.AccountTab();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    Developer.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args =
              data.argsAs<DeveloperArgs>(orElse: () => const DeveloperArgs());
          return _i5.DeveloperSettingsTab(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    ConversationsRoute.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i6.Conversations();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    ContactInfo.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i7.YourContactInfo();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    NewMessage.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i8.NewMessage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    AddQR.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i9.AddViaQR();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    AddUsername.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i10.AddViaUsername();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    Conversation.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<ConversationArgs>();
          return _i11.Conversation(args.contact);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false)
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(Home.name, path: '/', guards: [
          routerObserver
        ], children: [
          _i1.RouteConfig(MessagesRouter.name, path: 'messages', children: [
            _i1.RouteConfig(ConversationsRoute.name, path: ''),
            _i1.RouteConfig(ContactInfo.name, path: 'contactInfo'),
            _i1.RouteConfig(NewMessage.name, path: 'newMessage'),
            _i1.RouteConfig(AddQR.name, path: 'addQR'),
            _i1.RouteConfig(AddUsername.name, path: 'addUsername'),
            _i1.RouteConfig(Conversation.name, path: 'conversation')
          ]),
          _i1.RouteConfig(Vpn.name, path: 'vpn'),
          _i1.RouteConfig(Account.name, path: 'account'),
          _i1.RouteConfig(Developer.name, path: 'developer')
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

class Vpn extends _i1.PageRouteInfo<VpnArgs> {
  Vpn({_i12.Key? key}) : super(name, path: 'vpn', args: VpnArgs(key: key));

  static const String name = 'Vpn';
}

class VpnArgs {
  const VpnArgs({this.key});

  final _i12.Key? key;
}

class Account extends _i1.PageRouteInfo {
  const Account() : super(name, path: 'account');

  static const String name = 'Account';
}

class Developer extends _i1.PageRouteInfo<DeveloperArgs> {
  Developer({_i12.Key? key})
      : super(name, path: 'developer', args: DeveloperArgs(key: key));

  static const String name = 'Developer';
}

class DeveloperArgs {
  const DeveloperArgs({this.key});

  final _i12.Key? key;
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
  Conversation({required _i13.Contact contact})
      : super(name,
            path: 'conversation', args: ConversationArgs(contact: contact));

  static const String name = 'Conversation';
}

class ConversationArgs {
  const ConversationArgs({required this.contact});

  final _i13.Contact contact;
}
