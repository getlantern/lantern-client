import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

String systemTrayIcon(bool connected) {
  if (connected) {
    return Platform.isWindows
        ? 'assets/images/lantern_connected_32.ico'
        : 'assets/images/lantern_connected_32.png';
  }
  return Platform.isWindows
      ? 'assets/images/lantern_disconnected_32.ico'
      : 'assets/images/lantern_disconnected_32.png';
}


class TrayHandler with TrayListener {
  factory TrayHandler() => _getInstance();

  static TrayHandler get instance => _getInstance();
  static TrayHandler? _instance;

  static TrayHandler _getInstance() {
    _instance ??= TrayHandler._internal();
    return _instance!;
  }

  TrayHandler._internal() {
    if (isDesktop()) {
      setupTray(false);
    }
  }

  Future<void> setupTray(bool isConnected) async {
    await trayManager.setIcon(systemTrayIcon(isConnected));
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'status',
          disabled: true,
          label: isConnected ? 'status_on'.i18n : 'status_off'.i18n,
        ),
        MenuItem(
          key: 'status',
          label: isConnected ? 'disconnect'.i18n : 'connect'.i18n,
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'show_window',
          label: 'show'.i18n,
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: 'exit'.i18n,
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        windowManager.focus();
        windowManager.setSkipTaskbar(false);
      case 'exit':
        windowManager.destroy();
        ffiExit();
      case 'status':
        final status = ffiVpnStatus().toDartString();
        bool isConnected = status == "connected";
        if (isConnected) {
          sysProxyOff();
          setupTray(false);
        } else {
          sysProxyOn();
          setupTray(true);
        }
    }
  }

  @override
  Future<void> onTrayIconMouseDown() async {
    windowManager.show();
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }
}