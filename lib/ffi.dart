import 'dart:ffi' as ffi; // For FFI
import 'package:lantern/common/common.dart';
import 'package:ffi/ffi.dart';
import 'package:ffi/src/utf8.dart';
import 'dart:convert';

typedef start_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
typedef Start = ffi.Pointer<Utf8> Function(); // Dart fn signature

typedef pro_func = ffi.Pointer<Utf8> Function();
typedef ProFunc = ffi.Pointer<Utf8> Function();

typedef sysproxy_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
typedef SysProxy = ffi.Pointer<Utf8> Function(); // Dart fn signature

typedef selecttab_func = ffi.Void Function(ffi.Pointer<Utf8>);
typedef SelectTab = void Function(ffi.Pointer<Utf8>);

typedef selectedtab_func = ffi.Pointer<Utf8> Function(); // FFI fn signature
typedef SelectedTab = ffi.Pointer<Utf8> Function(); // Dart fn signature

typedef setting_func = ffi.Pointer<Utf8> Function();
typedef Setting = ffi.Pointer<Utf8> Function();

final dylib = ffi.DynamicLibrary.open(Platform.isMacOS ? 'liblantern.dylib' : 'liblantern.dll');

final Start start =
    dylib.lookup<ffi.NativeFunction<start_func>>('Start').asFunction();

final SysProxy sysProxyOn =
    dylib.lookup<ffi.NativeFunction<start_func>>('SysProxyOn').asFunction();

final SysProxy sysProxyOff =
    dylib.lookup<ffi.NativeFunction<start_func>>('SysProxyOff').asFunction();

final SelectTab setSelectTab = 
    dylib.lookup<ffi.NativeFunction<selecttab_func>>('SetSelectTab').asFunction();

final SelectedTab ffiSelectedTab =
    dylib.lookup<ffi.NativeFunction<selectedtab_func>>('SelectedTab').asFunction();

final ProFunc ffiPlans = dylib.lookup<ffi.NativeFunction<pro_func>>('Plans').asFunction();
final ProFunc ffiPaymentMethods = dylib.lookup<ffi.NativeFunction<pro_func>>('PaymentMethods').asFunction();
final ProFunc getUserData = dylib.lookup<ffi.NativeFunction<pro_func>>('UserData').asFunction();
final ProFunc ffiEmailAddress = dylib.lookup<ffi.NativeFunction<pro_func>>('EmailAddress').asFunction();
final ProFunc ffiReferral = dylib.lookup<ffi.NativeFunction<pro_func>>('Referral').asFunction();
final ProFunc ffiReplicaAddr = dylib.lookup<ffi.NativeFunction<pro_func>>('ReplicaAddr').asFunction();
final ProFunc ffiChatEnabled = dylib.lookup<ffi.NativeFunction<pro_func>>('ChatEnabled').asFunction();
final ProFunc ffiCountry = dylib.lookup<ffi.NativeFunction<pro_func>>('Country').asFunction();
final ProFunc ffiLang = dylib.lookup<ffi.NativeFunction<pro_func>>('Lang').asFunction();
final ProFunc ffiAcceptedTermsVersion = dylib.lookup<ffi.NativeFunction<pro_func>>('AcceptedTermsVersion').asFunction();
final ProFunc ffiProUser = dylib.lookup<ffi.NativeFunction<pro_func>>('ProUser').asFunction();
final ProFunc ffiDeviceLinkingCode = dylib.lookup<ffi.NativeFunction<pro_func>>('DeviceLinkingCode').asFunction();
final ProFunc ffiDevelopmentMode = dylib.lookup<ffi.NativeFunction<pro_func>>('DevelopmentMode').asFunction();
final ProFunc ffiSplitTunneling = dylib.lookup<ffi.NativeFunction<pro_func>>('SplitTunneling').asFunction();
final ProFunc ffiChatMe = dylib.lookup<ffi.NativeFunction<pro_func>>('ChatMe').asFunction();
final ProFunc ffiPlayVersion = dylib.lookup<ffi.NativeFunction<pro_func>>('PlayVersion').asFunction();
final ProFunc ffiStoreVersion = dylib.lookup<ffi.NativeFunction<pro_func>>('StoreVersion').asFunction();
final ProFunc ffiHasSucceedingProxy = dylib.lookup<ffi.NativeFunction<pro_func>>('HasSucceedingProxy').asFunction();
final ProFunc ffiOnBoardingStatus = dylib.lookup<ffi.NativeFunction<pro_func>>('OnBoardingStatus').asFunction();
final ProFunc ffiSdkVersion = dylib.lookup<ffi.NativeFunction<pro_func>>('SdkVersion').asFunction();
final ProFunc ffiVpnStatus = dylib.lookup<ffi.NativeFunction<pro_func>>('VpnStatus').asFunction();
final ProFunc ffiEmailExists = dylib.lookup<ffi.NativeFunction<pro_func>>('EmailExists').asFunction();

void loadLibrary() {
  start();
}