export 'dart:convert';
export 'dart:ffi'; // For FFI

export 'package:ffi/ffi.dart';
export 'package:ffi/src/utf8.dart';
export 'package:lantern/common/config.dart';
export 'package:lantern/common/ffi_subscriber.dart';
export 'package:lantern/common/ffi_list_subscriber.dart';
export 'package:lantern/common/model.dart';
export 'package:lantern/common/ui/websocket.dart';
export 'package:lantern/common/websocket_subscriber.dart';
export 'package:lantern/ffi.dart';
export 'package:web_socket_channel/io.dart';
export 'package:web_socket_channel/web_socket_channel.dart';

import 'dart:io';
import 'package:lantern/ffi.dart';
import 'package:lantern/i18n/i18n.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

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

void setupTray(bool isConnected) async {
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
          onClick: (item) {
            if (isConnected) {
              LanternFFI.sysProxyOff();
            } else {
              LanternFFI.sysProxyOn();
            }
          }),
      MenuItem.separator(),
      MenuItem(
          key: 'show_window',
          label: 'show'.i18n,
          onClick: (item) {
            windowManager.focus();
            windowManager.setSkipTaskbar(false);
          }),
      MenuItem.separator(),
      MenuItem(
          key: 'exit',
          label: 'exit'.i18n,
          onClick: (item) {
            windowManager.destroy();
            LanternFFI.exit();
          }),
    ],
  );
  await trayManager.setContextMenu(menu);
}
