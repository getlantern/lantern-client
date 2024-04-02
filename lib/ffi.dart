import 'dart:ffi'; // For FFI
import 'dart:io';

import 'package:ffi/src/utf8.dart';
import 'package:lantern/common/common.dart';

import 'generated_bindings.dart';

void sysProxyOn() => _bindings.sysProxyOn();

void sysProxyOff() => _bindings.sysProxyOff();

void setSelectTab(tab) => _bindings.setSelectTab(tab);

void setLang(lang) => _bindings.setSelectLang(lang);

String websocketAddr() => _bindings.websocketAddr().cast<Utf8>().toDartString();

Pointer<Utf8> ffiVpnStatus() => _bindings.vpnStatus().cast<Utf8>();

Pointer<Utf8> ffiSelectedTab() => _bindings.selectedTab().cast<Utf8>();

Pointer<Utf8> ffiLang() => _bindings.lang().cast<Utf8>();

Pointer<Utf8> ffiPlayVersion() => _bindings.playVersion().cast<Utf8>();

Pointer<Utf8> ffiStoreVersion() => _bindings.storeVersion().cast<Utf8>();

Pointer<Utf8> ffiHasSucceedingProxy() =>
    _bindings.hasSucceedingProxy().cast<Utf8>();

Pointer<Utf8> ffiProUser() => _bindings.proUser().cast<Utf8>();

Future<User> ffiUserData() async {
  final res = await _bindings.userData().cast<Utf8>().toDartString();
  // it's necessary to use mergeFromProto3Json here instead of fromJson; otherwise, a FormatException with
  // message Invalid radix-10 number is thrown.In addition, all possible JSON fields have to be defined on
  // the User protobuf message or JSON decoding fails because of an "unknown field name" error:
  // Protobuf JSON decoding failed at: root["telephone"]. Unknown field name 'telephone'
  return User.create()..mergeFromProto3Json(jsonDecode(res));
}

// checkAPIError creates and returns an API response from the given json. It throws a PlatformException if
// the response contains an error
APIResponse checkAPIError(json, errorMessage) {
  final result = APIResponse.create()..mergeFromProto3Json(jsonDecode(json));
  if (result.error != "") {
    throw PlatformException(code: result.error, message: errorMessage);
  }
  return result;
}

Future<String> ffiApproveDevice(code) async {
  final json = await _bindings.approveDevice(code).cast<Utf8>().toDartString();
  checkAPIError(json, 'wrong_device_linking_code'.i18n);
  // refresh user data after successfully linking device
  await ffiUserData();
  return json;
}

Future<void> ffiRemoveDevice(deviceId) async {
  final json = await _bindings.removeDevice(deviceId).cast<Utf8>().toDartString();
  checkAPIError(json, 'cannot_remove_device'.i18n);
  return;
}

Pointer<Utf8> ffiDevices() => _bindings.devices().cast<Utf8>();

Pointer<Utf8> ffiDevelopmentMode() => _bindings.developmentMode().cast<Utf8>();

Pointer<Utf8> ffiAcceptedTermsVersion() =>
    _bindings.acceptedTermsVersion().cast<Utf8>();

Pointer<Utf8> ffiEmailAddress() => _bindings.emailAddress().cast<Utf8>();

Pointer<Utf8> ffiEmailExists(email) =>
    _bindings.emailExists(email).cast<Utf8>();

Pointer<Utf8> ffiRedeemResellerCode(email, currency, deviceName, resellerCode) {
  final result =
      _bindings.redeemResellerCode(email, currency, deviceName, resellerCode);
  // Check for error
  // it means you need to check r1
  if (result.r1 != nullptr) {
    // Got error throw error to show error ui state
    final errorCode = result.r1.cast<Utf8>().toDartString();
    throw PlatformException(code: errorCode, message: 'wrong_seller_code'.i18n);
  }
  // if successful redeeming a reseller code, immediately refresh Pro user data
  ffiProUser();
  return result.r0.cast<Utf8>();
}

Pointer<Utf8> ffiReferral() => _bindings.referral().cast<Utf8>();

Pointer<Utf8> ffiReplicaAddr() => _bindings.replicaAddr().cast<Utf8>();

Pointer<Utf8> ffiChatEnabled() => _bindings.chatEnabled().cast<Utf8>();

Pointer<Utf8> ffiSdkVersion() => _bindings.sdkVersion().cast<Utf8>();

Pointer<Utf8> ffiCheckUpdates() => _bindings.checkUpdates().cast<Utf8>();

Pointer<Utf8> ffiPlans() => _bindings.plans().cast<Utf8>();

Pointer<Utf8> ffiPaymentMethods() => _bindings.paymentMethods().cast<Utf8>();

Pointer<Utf8> ffiDeviceLinkingCode() =>
    _bindings.deviceLinkingCode().cast<Utf8>();

Pointer<Utf8> ffiExpiryDate() => _bindings.expiryDate().cast<Utf8>();

Pointer<Utf8> ffiSplitTunneling() => _bindings.splitTunneling().cast<Utf8>();

Pointer<Utf8> ffiChatMe() => _bindings.chatMe().cast<Utf8>();

Pointer<Utf8> ffiOnBoardingStatus() =>
    _bindings.onBoardingStatus().cast<Utf8>();

Pointer<Utf8> ffiServerInfo() => _bindings.serverInfo().cast<Utf8>();

Future<void> ffiReportIssue(List<String> list) {
  final email = list[0].toNativeUtf8();
  final issueType = list[1].toNativeUtf8();
  final description = list[2].toNativeUtf8();
  final result = _bindings.reportIssue(email as Pointer<Char>, issueType as Pointer<Char>, description as Pointer<Char>);
  if (result.r1 != nullptr) {
    // Got error throw error to show error ui state
    final errorCode = result.r1.cast<Utf8>().toDartString();
    throw PlatformException(
        code: errorCode, message: 'report_issue_error'.i18n);
  }
  return Future.value();
}


String ffiPaymentRedirect(planID, currency, provider, email, deviceName) {
  final result =
      _bindings.paymentRedirect(planID, currency, provider, email, deviceName);
  if (result.r1 != nullptr) {
    // Got error throw error to show error ui state
    final errorCode = result.r1.cast<Utf8>().toDartString();
    throw PlatformException(
        code: errorCode,
        message: 'we_are_experiencing_technical_difficulties'.i18n);
  }
  return result.r0.cast<Utf8>().toDartString();
}

const String _libName = 'liblantern';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS) {
    return DynamicLibrary.open('$_libName.dylib');
  }
  if (Platform.isLinux) {
    String dir = Directory.current.path;
    return DynamicLibrary.open('$dir/$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [dylib].
final NativeLibrary _bindings = NativeLibrary(_dylib);

void loadLibrary() {
  _bindings.start();
}
