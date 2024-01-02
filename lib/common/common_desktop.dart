export 'dart:convert';
export 'dart:ffi'; // For FFI

export 'package:lantern/ffi.dart';
export 'package:ffi/ffi.dart';
export 'package:ffi/src/utf8.dart';

import 'dart:io' show Platform;

bool isDesktop() {
  return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
}
