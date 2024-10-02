import 'dart:io';

import 'package:lantern/common/ui/image_paths.dart';

export 'dart:convert';
export 'dart:ffi'; // For FFI
export 'package:ffi/src/utf8.dart';
export 'package:lantern/core/utils/config.dart';
export 'package:lantern/core/subscribers/ffi_subscriber.dart';
export 'package:lantern/core/subscribers/ffi_list_subscriber.dart';
export 'package:lantern/core/native/model.dart';
export 'package:lantern/core/service/websocket.dart';
export 'package:lantern/core/service/websocket_subscriber.dart';
export 'package:lantern/core/service/lantern_ffi_service.dart';
export 'package:web_socket_channel/io.dart';
export 'package:web_socket_channel/web_socket_channel.dart';


String getSystemTrayIconPath(bool connected) {
  if (connected) {
    return Platform.isWindows
        ? ImagePaths.lanternConnectedIco
        : ImagePaths.lanternConnected;
  }
  return Platform.isWindows
      ? ImagePaths.lanternDisconnectedIco
      : ImagePaths.lanternDisconnected;
}