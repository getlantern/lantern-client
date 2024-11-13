import 'dart:io';

import 'package:flutter/material.dart';
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

String getSystemTrayIconPath(bool connected, isDarkMode) {
  if (Platform.isWindows) {
    return connected
        ? ImagePaths.lanternConnectedIco
        : ImagePaths.lanternDisconnectedIco;
  } else if (Platform.isMacOS) {
    // Check if the theme is dark
    if (isDarkMode) {
      return connected
          ? ImagePaths.lanternLightConnected
          : ImagePaths.lanternLightDisconnected;
    }
    return connected
        ? ImagePaths.lanternDarkConnected
        : ImagePaths.lanternDarkDisconnected;
  }

  return connected
      ? ImagePaths.lanternConnected
      : ImagePaths.lanternDisconnected;
}
