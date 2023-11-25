import 'dart:ffi' as ffi; // For FFI
import 'package:ffi/ffi.dart';
import 'package:ffi/src/utf8.dart';
import 'dart:convert';

typedef start_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
typedef Start = ffi.Pointer<Utf8> Function(); // Dart fn signature

typedef pro_func = ffi.Pointer<Utf8> Function();
typedef ProFunc = ffi.Pointer<Utf8> Function();

typedef sysproxy_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
typedef SysProxy = ffi.Pointer<Utf8> Function(); // Dart fn signature

final dylib = ffi.DynamicLibrary.open('liblantern.dylib');

final Start start =
    dylib.lookup<ffi.NativeFunction<start_func>>('Start').asFunction();

final SysProxy sysProxyOn =
    dylib.lookup<ffi.NativeFunction<start_func>>('SysProxyOn').asFunction();

final SysProxy sysProxyOff =
    dylib.lookup<ffi.NativeFunction<start_func>>('SysProxyOff').asFunction();

final ProFunc getPlans = dylib.lookup<ffi.NativeFunction<pro_func>>('Plans').asFunction();
final ProFunc getUserData = dylib.lookup<ffi.NativeFunction<pro_func>>('UserData').asFunction();

void loadLibrary() {
  start();
}