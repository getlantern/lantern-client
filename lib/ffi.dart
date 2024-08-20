import 'dart:ffi'; // For FFI

import 'package:ffi/src/utf8.dart';
import 'package:lantern/common/common.dart';

import 'generated_bindings.dart';

extension StringEx on String {
  Pointer<Char> toPointerChar() {
    return toNativeUtf8().cast<Char>();
  }

  bool toBool() {
    return this == 'true';
  }
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

void sysProxyOn() => _bindings.sysProxyOn();

void sysProxyOff() => _bindings.sysProxyOff();

void setLang(lang) => _bindings.setSelectLang(lang);

void ffiSetProxyAll(String isOn) => _bindings.setProxyAll(isOn.toPointerChar());

String websocketAddr() => _bindings.websocketAddr().cast<Utf8>().toDartString();

void ffiExit() {
  _bindings.exitApp();
}

Pointer<Utf8> ffiVpnStatus() => _bindings.vpnStatus().cast<Utf8>();

Pointer<Utf8> ffiLang() => _bindings.lang().cast<Utf8>();

Pointer<Utf8> ffiPlayVersion() => _bindings.playVersion().cast<Utf8>();

Pointer<Utf8> ffiProxyAll() => _bindings.proxyAll().cast<Utf8>();

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

(bool, bool, bool) startUpInitCallBacks() {
  final proxy = _bindings.hasProxyFected().cast<Utf8>().toDartString();
  final config = _bindings.hasConfigFected().cast<Utf8>().toDartString();
  final success = _bindings.onSuccess().cast<Utf8>().toDartString();
  print("startup status proxy $proxy config $config success $success");
  return (proxy.toBool(), config.toBool(), success.toBool());
}

Future<String> ffiApproveDevice(String code) async {
  final json = await _bindings
      .approveDevice(code.toPointerChar())
      .cast<Utf8>()
      .toDartString();
  final result = BaseResponse.create()..mergeFromProto3Json(jsonDecode(json));
  checkAPIError(result, 'wrong_device_linking_code'.i18n);
  // refresh user data after successfully linking device
  await ffiUserData();
  return json;
}

Future<void> ffiRemoveDevice(String deviceId) async {
  final json = await _bindings
      .removeDevice(deviceId.toPointerChar())
      .cast<Utf8>()
      .toDartString();
  final result = LinkResponse.create()..mergeFromProto3Json(jsonDecode(json));
  checkAPIError(result, 'cannot_remove_device'.i18n);
  // refresh user data after removing a device
  await ffiUserData();
  return;
}

Future<String> ffiAuthorizeEmail(String emailAddress) async {
  final json = await _bindings
      .approveDevice(emailAddress.toPointerChar())
      .cast<Utf8>()
      .toDartString();
  final result = BaseResponse.create()..mergeFromProto3Json(jsonDecode(json));
  return json;
}

Future<String> ffiUserLinkValidate(String code) async {
  final json = await _bindings
      .userLinkValidate(code.toPointerChar())
      .cast<Utf8>()
      .toDartString();
  checkAPIError(json, "invalid_code".i18n);
  return json;
}

FutureOr<bool> ffiHasPlanUpdateOrBuy(dynamic context) {
  final json = _bindings.hasPlanUpdatedOrBuy().cast<Utf8>().toDartString();
  return json == 'true' ? true : throw NoPlansUpdate("No Plans update");
}

Pointer<Utf8> ffiDevices() => _bindings.devices().cast<Utf8>();

Pointer<Utf8> ffiDevelopmentMode() => _bindings.developmentMode().cast<Utf8>();

Pointer<Utf8> ffiAcceptedTermsVersion() =>
    _bindings.acceptedTermsVersion().cast<Utf8>();

Pointer<Utf8> ffiEmailAddress() => _bindings.emailAddress().cast<Utf8>();

Future<String> ffiEmailExists(String email) async => await _bindings
    .emailExists(email.toPointerChar())
    .cast<Utf8>()
    .toDartString();

Future<void> ffiRedeemResellerCode(List<String> params) {
  final email = params[0].toPointerChar();
  final currency = params[1].toPointerChar();
  final deviceName = params[2].toPointerChar();
  final resellerCode = params[3].toPointerChar();
  final result = _bindings
      .redeemResellerCode(email, currency, deviceName, resellerCode)
      .cast<Utf8>()
      .toDartString();
  checkAPIError(result, 'wrong_seller_code'.i18n);
  return Future.value();
}

Pointer<Utf8> ffiReferral() => _bindings.referral().cast<Utf8>();

Pointer<Utf8> ffiDeviceId() => _bindings.myDeviceId().cast<Utf8>();

Pointer<Utf8> ffiReplicaAddr() => _bindings.replicaAddr().cast<Utf8>();

Pointer<Utf8> ffiChatEnabled() => _bindings.chatEnabled().cast<Utf8>();

Pointer<Utf8> ffiAuthEnabled() => _bindings.authEnabled().cast<Utf8>();

Pointer<Utf8> ffiSdkVersion() => _bindings.sdkVersion().cast<Utf8>();

Pointer<Utf8> ffiCheckUpdates() => _bindings.checkUpdates().cast<Utf8>();

Pointer<Utf8> ffiPlans() => _bindings.plans().cast<Utf8>();

Pointer<Utf8> ffiPaymentMethods() => _bindings.paymentMethodsV3().cast<Utf8>();

Pointer<Utf8> ffiPaymentMethodsV4() =>
    _bindings.paymentMethodsV4().cast<Utf8>();

Pointer<Utf8> ffiDeviceLinkingCode() =>
    _bindings.deviceLinkingCode().cast<Utf8>();

Pointer<Utf8> ffiExpiryDate() => _bindings.expiryDate().cast<Utf8>();

Pointer<Utf8> ffiSplitTunneling() => _bindings.splitTunneling().cast<Utf8>();

Pointer<Utf8> ffiChatMe() => _bindings.chatMe().cast<Utf8>();

Pointer<Utf8> ffiOnBoardingStatus() =>
    _bindings.onBoardingStatus().cast<Utf8>();

Pointer<Utf8> ffiServerInfo() => _bindings.serverInfo().cast<Utf8>();

Future<void> ffiReportIssue(List<String> list) {
  final email = list[0].toPointerChar();
  final issueType = list[1].toPointerChar();
  final description = list[2].toPointerChar();
  final result = _bindings
      .reportIssue(email, issueType, description)
      .cast<Utf8>()
      .toDartString();

  checkAPIError(result, 'we_are_experiencing_technical_difficulties'.i18n);
  return Future.value();
}

Future<String> ffiPaymentRedirect(List<String> list) {
  final planID = list[0].toPointerChar();
  final currency = list[1].toPointerChar();
  final provider = list[2].toPointerChar();
  final email = list[3].toPointerChar();
  final deviceName = list[4].toPointerChar();
  final json = _bindings
      .paymentRedirect(planID, currency, provider, email, deviceName)
      .cast<Utf8>()
      .toDartString();
  final result = PaymentRedirectResponse.create()
    ..mergeFromProto3Json(jsonDecode(json));
  checkAPIError(result, 'we_are_experiencing_technical_difficulties'.i18n);
  return Future.value(result.redirect);
}

Future<void> ffiTestPaymentRequest(List<String> params) {
  final email = params[0].toPointerChar();
  final paymentProvider = params[1].toPointerChar();
  final planId = params[2].toPointerChar();
  final result = _bindings
      .testProviderRequest(email, paymentProvider, planId)
      .cast<Utf8>()
      .toDartString();
  checkAuthAPIError(result);
  return Future.value();
}

/// Auth methods for desktop

/// FFI pointer to the native function
Pointer<Utf8> ffiIsUserLoggedIn() {
  final result = _bindings.isUserLoggedIn().cast<Utf8>();
  print(result.toDartString());
  return result;
}

/// FFI function
Future<bool> ffiUserFirstVisit() {
  final result = _bindings.isUserFirstTime().cast<Utf8>().toDartString();
  return Future.value(result == 'true');
}

void setUserFirstTimeVisit() => _bindings.setFirstTimeVisit();

///signup
Future<void> ffiSignUp(List<String> params) {
  final email = params[0].toPointerChar();
  final password = params[1].toPointerChar();
  final result = _bindings.signup(email, password).cast<Utf8>().toDartString();
  checkAuthAPIError(result);
  return Future.value(result.toBool());
}

/// login
Future<void> ffiLogin(List<String> params) {
  final email = params[0].toPointerChar();
  final password = params[1].toPointerChar();
  final result = _bindings.login(email, password).cast<Utf8>().toDartString();
  checkAuthAPIError(result);
  return Future.value(result.toBool());
}

/// logout
Future<void> ffiLogout(dynamic context) {
  final result = _bindings.logout().cast<Utf8>().toDartString();
  checkAuthAPIError(result);
  return Future.value(result.toBool());
}

/// start recovery by email
/// send verification code to email
Future<void> ffiStartRecoveryByEmail(String email) {
  final result = _bindings
      .startRecoveryByEmail(email.toPointerChar())
      .cast<Utf8>()
      .toDartString();
  checkAuthAPIError(result);
  return Future.value(result.toBool());
}

/// start recovery by email
/// send verification code to email
Future<void> ffiValidateRecoveryByEmail(List<String> params) {
  final email = params[0].toPointerChar();
  final code = params[1].toPointerChar();
  final result = _bindings
      .validateRecoveryByEmail(email, code)
      .cast<Utf8>()
      .toDartString();
  checkAuthAPIError(result);
  return Future.value(result.toBool());
}

Future<void> ffiCompleteRecoveryByEmail(List<String> params) {
  final email = params[0].toPointerChar();
  final password = params[1].toPointerChar();
  final code = params[2].toPointerChar();
  final result = _bindings
      .completeRecoveryByEmail(email, code, password)
      .cast<Utf8>()
      .toDartString();
  checkAuthAPIError(result);
  return Future.value(result.toBool());
}

Future<void> ffiDeleteAccount(String password) {
  final result = _bindings
      .deleteAccount(password.toPointerChar())
      .cast<Utf8>()
      .toDartString();
  checkAuthAPIError(result);
  return Future.value(result.toBool());
}

//Custom exception for handling error
class NoPlansUpdate implements Exception {
  String message;

  NoPlansUpdate(this.message);
}

// checkAPIError throws a PlatformException if the API response contains an error
void checkAPIError(result, errorMessage) {
  if (result is String) {
    if (result == 'true') {
      return;
    }
    final errorMessageMap = jsonDecode(result);
    if (errorMessageMap.containsKey('error')) {
      throw PlatformException(
          code: errorMessageMap['error'], message: errorMessage);
    }
    return;
  }
  if (result.error != "") {
    throw PlatformException(code: result.error, message: errorMessage);
  }
}

void checkAuthAPIError(result) {
  if (result is String) {
    if (result == "true") {
      return;
    }
    final errorMessageMap = jsonDecode(result);
    if (errorMessageMap.containsKey('error')) {
      throw PlatformException(
          code: errorMessageMap['error'], message: errorMessageMap['error']);
    }
    return;
  }
}
