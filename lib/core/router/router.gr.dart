// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;
import 'package:lantern/package_store.dart' as _i5;
import 'package:lantern/ui/index.dart' as _i3;
import 'package:lantern/ui/widgets/account/developer_settings.dart' as _i4;

class AppRouter extends _i1.RootStackRouter {
  AppRouter([_i2.GlobalKey<_i2.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    Main.name: (routeData) => _i1.AdaptivePage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<MainArgs>(orElse: () => const MainArgs());
          return _i3.HomePage(key: args.key);
        }),
    Messages.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i3.MessagesTab();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    Vpn.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<VpnArgs>(orElse: () => const VpnArgs());
          return _i3.VPNTab(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false),
    Account.name: (routeData) => _i1.CustomPage<void>(
        routeData: routeData,
        builder: (_) {
          return _i3.AccountTab();
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
          return _i4.DeveloperSettingsTab(key: args.key);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        durationInMilliseconds: 400,
        opaque: true,
        barrierDismissible: false)
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig('/#redirect',
            path: '/', redirectTo: '/main', fullMatch: true),
        _i1.RouteConfig(Main.name, path: '/main', children: [
          _i1.RouteConfig(Messages.name, path: 'messages'),
          _i1.RouteConfig(Vpn.name, path: 'vpn'),
          _i1.RouteConfig(Account.name, path: 'account'),
          _i1.RouteConfig(Developer.name, path: 'developer')
        ])
      ];
}

class Main extends _i1.PageRouteInfo<MainArgs> {
  Main({_i5.Key? key, List<_i1.PageRouteInfo>? children})
      : super(name,
            path: '/main', args: MainArgs(key: key), initialChildren: children);

  static const String name = 'Main';
}

class MainArgs {
  const MainArgs({this.key});

  final _i5.Key? key;
}

class Messages extends _i1.PageRouteInfo {
  const Messages() : super(name, path: 'messages');

  static const String name = 'Messages';
}

class Vpn extends _i1.PageRouteInfo<VpnArgs> {
  Vpn({_i5.Key? key}) : super(name, path: 'vpn', args: VpnArgs(key: key));

  static const String name = 'Vpn';
}

class VpnArgs {
  const VpnArgs({this.key});

  final _i5.Key? key;
}

class Account extends _i1.PageRouteInfo {
  const Account() : super(name, path: 'account');

  static const String name = 'Account';
}

class Developer extends _i1.PageRouteInfo<DeveloperArgs> {
  Developer({_i5.Key? key})
      : super(name, path: 'developer', args: DeveloperArgs(key: key));

  static const String name = 'Developer';
}

class DeveloperArgs {
  const DeveloperArgs({this.key});

  final _i5.Key? key;
}
