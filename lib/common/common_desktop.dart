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

 String getSystemTrayIconPath (bool connected) {
  if (connected) {
    return Platform.isWindows
        ? 'assets/images/lantern_connected_32.ico'
        : 'assets/images/lantern_connected_32.png';
  }
  return Platform.isWindows
      ? 'assets/images/lantern_disconnected_32.ico'
      : 'assets/images/lantern_disconnected_32.png';
}

