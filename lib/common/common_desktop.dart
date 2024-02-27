export 'dart:convert';
export 'dart:ffi'; // For FFI

export 'package:lantern/ffi.dart';
export 'package:ffi/ffi.dart';
export 'package:ffi/src/utf8.dart';

import 'package:tray_manager/tray_manager.dart';
import 'package:lantern/common/common.dart';
import 'dart:io' show Platform;

bool isMobile() {
  return Platform.isAndroid || Platform.isIOS;
}

bool isDesktop() {
  return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
}

String systemTrayIcon(bool connected) {
  if (connected) {
    return  Platform.isWindows ? 'assets/images/lantern_connected_32.ico' :
            'assets/images/lantern_connected_32.png';
  }
  return Platform.isWindows ? 'assets/images/lantern_disconnected_32.ico' :
            'assets/images/lantern_disconnected_32.png';
}

Future<void> setupMenu(bool isConnected) async {
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
  await trayManager.setIcon(systemTrayIcon(isConnected));
}