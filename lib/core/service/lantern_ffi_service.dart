import 'dart:ffi'; // For FFI

import 'package:ffi/src/utf8.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/common_desktop.dart';

import '../../generated_bindings.dart';

extension StringEx on String {
  Pointer<Char> toPointerChar() {
    return toNativeUtf8().cast<Char>();
  }

  bool toBool() {
    return this == 'true';
  }
}

const String _libName = 'liblantern';

//Custom exception for handling error
class NoPlansUpdate implements Exception {
  String message;

  NoPlansUpdate(this.message);
}

class LanternFFI {
  static final NativeLibrary _lanternFFI = NativeLibrary(_getLanternLib());

  static DynamicLibrary _getLanternLib() {
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
    throw Exception("Platform is not supported");
  }

  static startDesktopService() => _lanternFFI.start();

  static void sysProxyOn() => _lanternFFI.sysProxyOn();

  static void sysProxyOff() => _lanternFFI.sysProxyOff();

  static void setLang(String lang) => _lanternFFI.setSelectLang(lang.toPointerChar());

  static void setProxyAll(String isOn) =>
      _lanternFFI.setProxyAll(isOn.toPointerChar());

  static String websocketAddr() =>
      _lanternFFI.websocketAddr().cast<Utf8>().toDartString();

  static void exit() {
    _lanternFFI.exitApp();
    //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  static Future<User> ffiUserData() async {
    final res = await _lanternFFI.userData().cast<Utf8>().toDartString();
    // it's necessary to use mergeFromProto3Json here instead of fromJson; otherwise, a FormatException with
    // message Invalid radix-10 number is thrown.In addition, all possible JSON fields have to be defined on
    // the User protobuf message or JSON decoding fails because of an "unknown field name" error:
    // Protobuf JSON decoding failed at: root["telephone"]. Unknown field name 'telephone'
    return User.create()..mergeFromProto3Json(jsonDecode(res));
  }


  static Future<String> approveDevice(String code) async {
    final json = await _lanternFFI
        .approveDevice(code.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    checkAPIError(json, 'wrong_device_linking_code'.i18n);
    final result = BaseResponse.create()..mergeFromProto3Json(jsonDecode(json));
    // refresh user data after successfully linking device
    await ffiUserData();
    return json;
  }

  static Future<void> removeDevice(String deviceId) async {
    final json = await _lanternFFI
        .removeDevice(deviceId.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    checkAPIError(json, 'cannot_remove_device'.i18n);
    final result = LinkResponse.create()..mergeFromProto3Json(jsonDecode(json));
    // refresh user data after removing a device
    await ffiUserData();
    return;
  }

  static Future<String> authorizeEmail(String email) async {
    final json = await _lanternFFI
        .approveDevice(email.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    final result = BaseResponse.create()..mergeFromProto3Json(jsonDecode(json));
    return json;
  }

  static Future<String> userLinkValidate(String code) async {
    final json = await _lanternFFI
        .userLinkValidate(code.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    checkAPIError(json, "invalid_code".i18n);
    return json;
  }

  static FutureOr<bool> hasPlanUpdateOrBuy(dynamic context) {
    final json = _lanternFFI.hasPlanUpdatedOrBuy().cast<Utf8>().toDartString();
    return json == 'true' ? true : throw NoPlansUpdate("No Plans update");
  }

  static Future<String> emailExists(String email) async => await _lanternFFI
      .emailExists(email.toPointerChar())
      .cast<Utf8>()
      .toDartString();

  static Future<void> redeemResellerCode(List<String> params) {
    final email = params[0].toPointerChar();
    final currency = params[1].toPointerChar();
    final deviceName = params[2].toPointerChar();
    final resellerCode = params[3].toPointerChar();
    final result = _lanternFFI
        .redeemResellerCode(email, currency, deviceName, resellerCode)
        .cast<Utf8>()
        .toDartString();
    checkAPIError(result, 'wrong_seller_code'.i18n);
    return Future.value();
  }

  static Pointer<Utf8> checkUpdates() =>
      _lanternFFI.checkUpdates().cast<Utf8>();

  static Pointer<Utf8> paymentMethods() =>
      _lanternFFI.paymentMethodsV3().cast<Utf8>();

  static Pointer<Utf8> paymentMethodsV4() =>
      _lanternFFI.paymentMethodsV4().cast<Utf8>();

  static Future<void> reportIssue(List<String> list) {
    final email = list[0].toPointerChar();
    final issueType = list[1].toPointerChar();
    final description = list[2].toPointerChar();
    final result = _lanternFFI
        .reportIssue(email, issueType, description)
        .cast<Utf8>()
        .toDartString();

    checkAPIError(result, 'we_are_experiencing_technical_difficulties'.i18n);
    return Future.value();
  }

  static Future<String> paymentRedirect(List<String> list) {
    final planID = list[0].toPointerChar();
    final currency = list[1].toPointerChar();
    final provider = list[2].toPointerChar();
    final email = list[3].toPointerChar();
    final deviceName = list[4].toPointerChar();
    try {
      final json = _lanternFFI
          .paymentRedirect(planID, currency, provider, email, deviceName)
          .cast<Utf8>()
          .toDartString();
      checkAPIError(json, 'we_are_experiencing_technical_difficulties'.i18n);
      final result = PaymentRedirectResponse.create()
        ..mergeFromProto3Json(jsonDecode(json));
      return Future.value(result.redirect);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Pointer<Utf8> ffIsPlayVersion() => "false".toPointerChar().cast<Utf8>();


  static Future<void> ffiApplyRefCode(String refCode) {
    final code = refCode.toPointerChar();
    final result = _lanternFFI.applyRef(code).cast<Utf8>().toDartString();
    checkAPIError(result, 'we_are_experiencing_technical_difficulties'.i18n);
    return Future.value();
  }


  static Future<void> testPaymentRequest(List<String> params) {
    final email = params[0].toPointerChar();
    final paymentProvider = params[1].toPointerChar();
    final planId = params[2].toPointerChar();
    final result = _lanternFFI
        .testProviderRequest(email, paymentProvider, planId)
        .cast<Utf8>()
        .toDartString();
    checkAuthAPIError(result);
    return Future.value();
  }

  /// Auth methods for desktop

  /// FFI pointer to the native function
  static Pointer<Utf8> isUserLoggedIn() {
    final result = _lanternFFI.isUserLoggedIn().cast<Utf8>();
    print(result.toDartString());
    return result;
  }

  /// FFI function
  static Future<bool> userFirstVisit() {
    final result = _lanternFFI.isUserFirstTime().cast<Utf8>().toDartString();
    return Future.value(result == 'true');
  }

  static void setUserFirstTimeVisit() => _lanternFFI.setFirstTimeVisit();

  ///signup
  static Future<void> signUp(List<String> params) {
    final email = params[0].toPointerChar();
    final password = params[1].toPointerChar();
    final result =
        _lanternFFI.signup(email, password).cast<Utf8>().toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  /// login
  static Future<void> login(List<String> params) {
    final email = params[0].toPointerChar();
    final password = params[1].toPointerChar();
    final result =
        _lanternFFI.login(email, password).cast<Utf8>().toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  /// logout
  static Future<void> logout(dynamic context) {
    final result = _lanternFFI.logout().cast<Utf8>().toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  /// start recovery by email
  /// send verification code to email
  static Future<void> startRecoveryByEmail(String email) {
    final result = _lanternFFI
        .startRecoveryByEmail(email.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  /// start recovery by email
  /// send verification code to email
  static Future<void> validateRecoveryByEmail(List<String> params) {
    final email = params[0].toPointerChar();
    final code = params[1].toPointerChar();
    final result = _lanternFFI
        .validateRecoveryByEmail(email, code)
        .cast<Utf8>()
        .toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  static Future<void> completeRecoveryByEmail(List<String> params) {
    final email = params[0].toPointerChar();
    final password = params[1].toPointerChar();
    final code = params[2].toPointerChar();
    final result = _lanternFFI
        .completeRecoveryByEmail(email, code, password)
        .cast<Utf8>()
        .toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  static Future<void> deleteAccount(String password) {
    final result = _lanternFFI
        .deleteAccount(password.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }
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

// final lanternFFI = LanternFFI;
