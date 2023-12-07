import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lantern/account/account_tab.dart';
import 'package:lantern/account/developer_settings.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/messaging/chats.dart';
import 'package:lantern/messaging/onboarding/welcome.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/replica/replica_tab.dart';
import 'package:lantern/vpn/try_lantern_chat.dart';
import 'package:lantern/vpn/vpn_tab.dart';
import 'package:logger/logger.dart';
import 'package:lantern/core/router/router.dart';
import 'package:lantern/messaging/messaging.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final globalRouter = AppRouter();
final networkWarningBarHeightRatio = ValueNotifier(0.0);
var showConnectivityWarning = false;

// This enum is used to manage the font families used in the application
enum AppFontFamily {
  semim('Samim'),
  roboto('Roboto');

  // the actual string value (the font family name) to each enum value
  const AppFontFamily(this.fontFamily);

  final String fontFamily;
}

class _TickerProviderImpl extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

class DesktopApp extends StatefulWidget {
  const DesktopApp({Key? key}) : super(key: key);

  @override
  State<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lantern Desktop'.i18n,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: buildBody(TAB_VPN),
        bottomNavigationBar: CustomBottomBar(
          selectedTab: TAB_VPN,
          isDevelop: true,
        ),
      ),
    );
  }

  Widget buildBody(String selectedTab) {
    switch (selectedTab) {
      case TAB_VPN:
        return VPNTab();
      case TAB_REPLICA:
        return ReplicaTab();
      case TAB_ACCOUNT:
        return AccountTab();
      case TAB_DEVELOPER:
        return DeveloperSettingsTab();
      default:
        assert(false, 'unrecognized tab $selectedTab');
        return Container();
    }
  }
}
