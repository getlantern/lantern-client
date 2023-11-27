import 'dart:ffi' as ffi; // For FFI
import 'package:ffi/ffi.dart';
import 'package:ffi/src/utf8.dart';
import 'dart:convert';
final dylib = ffi.DynamicLibrary.open('liblantern.dylib');

typedef start_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
typedef Start = ffi.Pointer<Utf8> Function(); // Dart fn signature
//
// typedef pro_func = ffi.Pointer<Utf8> Function();
// typedef ProFunc = ffi.Pointer<Utf8> Function();
//
typedef sysproxy_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
typedef SysProxy = ffi.Pointer<Utf8> Function(); // Dart fn signature

// typedef selecttab_func = ffi.Void Function(ffi.Pointer<Utf8>);
// typedef SelectTab = void Function(ffi.Pointer<Utf8>);
//
// typedef selectedtab_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
// typedef SelectedTab = ffi.Pointer<Utf8> Function(); // Dart fn signature
//
// typedef setting_func = ffi.Pointer<Utf8> Function();
// typedef Setting = ffi.Pointer<Utf8> Function();
//

//
final Start start =
    dylib.lookup<ffi.NativeFunction<start_func>>('Start').asFunction();

final SysProxy sysProxyOn =
    dylib.lookup<ffi.NativeFunction<start_func>>('SysProxyOn').asFunction();

final SysProxy sysProxyOff =
    dylib.lookup<ffi.NativeFunction<start_func>>('SysProxyOff').asFunction();
//
// final SelectTab setSelectTab =
//     dylib.lookup<ffi.NativeFunction<selecttab_func>>('SetSelectTab').asFunction();
//
// final SelectedTab selectedTab =
//     dylib.lookup<ffi.NativeFunction<selectedtab_func>>('SelectedTab').asFunction();
//
// final ProFunc getPlans = dylib.lookup<ffi.NativeFunction<pro_func>>('Plans').asFunction();
// final ProFunc getUserData = dylib.lookup<ffi.NativeFunction<pro_func>>('UserData').asFunction();
// final ProFunc ffiEmailAddress = dylib.lookup<ffi.NativeFunction<pro_func>>('EmailAddress').asFunction();
// final ProFunc ffiReplicaAddr = dylib.lookup<ffi.NativeFunction<pro_func>>('ReplicaAddr').asFunction();
// final ProFunc ffiChatEnabled = dylib.lookup<ffi.NativeFunction<pro_func>>('ChatEnabled').asFunction();
// final ProFunc ffiProUser = dylib.lookup<ffi.NativeFunction<pro_func>>('ProUser').asFunction();
// final ProFunc ffiEmailExists = dylib.lookup<ffi.NativeFunction<pro_func>>('EmailExists').asFunction();
//
void loadLibrary() {
  start();
}