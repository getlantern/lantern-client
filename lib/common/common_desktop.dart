import 'package:lantern/common/common.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:lantern/ffi.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi';
import 'package:lantern/common/ui/websocket.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'dart:convert';
export 'dart:ffi'; // For FFI
export 'package:ffi/ffi.dart';
export 'package:ffi/src/utf8.dart';
export 'package:lantern/ffi.dart';
export 'package:lantern/common/ui/websocket.dart';
export 'package:web_socket_channel/io.dart';
export 'package:web_socket_channel/web_socket_channel.dart';

// Include resources here just for desktop compatibility or use

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

// void setSelectedTab(BuildContext context, String name) {
//   final tab = name.toNativeUtf8();
//   final currentTab = ffiSelectedTab().toDartString();
//   setSelectTab(tab);
//   // when the user clicks on the active tab again, do nothing
//   if (currentTab == name) return;
//   // context.pushRoute(Home());
// }

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
