import 'package:flutter/material.dart';
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
import 'package:system_tray/system_tray.dart';

class DesktopApp extends StatefulWidget {
  const DesktopApp({Key? key}) : super(key: key);

  @override
  State<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {

  final AppWindow appWindow = AppWindow();
  final SystemTray systemTray = SystemTray();
  // create context menu
  final Menu menu = Menu();

  @override
  void initState() {
    super.initState();
    //initSystemTray();
  }

  String getTrayImagePath(String imageName) {
    return Platform.isWindows ? 'assets/images/tray/$imageName.ico' : 'assets/images/tray/$imageName.png';
  }

  Future<void> initSystemTray() async {

    await systemTray.initSystemTray(
      title: 'Lantern'.i18n,
      iconPath: getTrayImagePath('lantern_disconnected_32'),
    );

    await menu.buildFrom([
      MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
      MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) => appWindow.close()),
    ]);

    // set context menu
    await systemTray.setContextMenu(menu);

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      }
    });
  }

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
