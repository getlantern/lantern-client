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

//Custom exception for handling error
class NoPlansUpdate implements Exception {
  String message;

  NoPlansUpdate(this.message);
}

class LanternFFI {
  static LanternFFI? _instance;

  late final NativeLibrary lanternFFI;
  late final DynamicLibrary lib;

  DynamicLibrary _getLanternLib() {
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
    throw "Platform is not supported";
  }

  LanternFFI._internal() {
    lib = _getLanternLib();
    lanternFFI = NativeLibrary(lib);
  }

  factory LanternFFI() {
    _instance ??= LanternFFI._internal();
    return _instance!;
  }

  Future<void> start() async => await lanternFFI.start();

  void sysProxyOn() => lanternFFI.sysProxyOn();

  void sysProxyOff() => lanternFFI.sysProxyOff();

  void setLang(lang) => lanternFFI.setSelectLang(lang);

  void setProxyAll(String isOn) => lanternFFI.setProxyAll(isOn.toPointerChar());

  String websocketAddr() => lanternFFI.websocketAddr().cast<Utf8>().toDartString();

  void exit() {
    lanternFFI.exitApp();
    //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  Pointer<Utf8> vpnStatus() => lanternFFI.vpnStatus().cast<Utf8>();

  Pointer<Utf8> lang() => lanternFFI.lang().cast<Utf8>();

  Pointer<Utf8> proxyAll() => lanternFFI.proxyAll().cast<Utf8>();

  Pointer<Utf8> ffiStoreVersion() => lanternFFI.storeVersion().cast<Utf8>();

  Pointer<Utf8> hasSucceedingProxy() =>
      lanternFFI.hasSucceedingProxy().cast<Utf8>();

  Pointer<Utf8> proUser() => lanternFFI.proUser().cast<Utf8>();

  Future<User> ffiUserData() async {
    final res = await lanternFFI.userData().cast<Utf8>().toDartString();
    // it's necessary to use mergeFromProto3Json here instead of fromJson; otherwise, a FormatException with
    // message Invalid radix-10 number is thrown.In addition, all possible JSON fields have to be defined on
    // the User protobuf message or JSON decoding fails because of an "unknown field name" error:
    // Protobuf JSON decoding failed at: root["telephone"]. Unknown field name 'telephone'
    return User.create()..mergeFromProto3Json(jsonDecode(res));
  }

  (bool, bool, bool) startUpInitCallBacks() {
    final proxy = lanternFFI.hasProxyFected().cast<Utf8>().toDartString();
    final config = lanternFFI.hasConfigFected().cast<Utf8>().toDartString();
    final success = lanternFFI.onSuccess().cast<Utf8>().toDartString();
    print("startup status proxy $proxy config $config success $success");
    return (proxy.toBool(), config.toBool(), success.toBool());
  }

  Future<String> approveDevice(String code) async {
    final json = await lanternFFI
        .approveDevice(code.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    final result = BaseResponse.create()..mergeFromProto3Json(jsonDecode(json));
    checkAPIError(result, 'wrong_device_linking_code'.i18n);
    // refresh user data after successfully linking device
    await ffiUserData();
    return json;
  }

  Future<void> removeDevice(String deviceId) async {
    final json = await lanternFFI
        .removeDevice(deviceId.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    final result = LinkResponse.create()..mergeFromProto3Json(jsonDecode(json));
    checkAPIError(result, 'cannot_remove_device'.i18n);
    // refresh user data after removing a device
    await ffiUserData();
    return;
  }

  Future<String> authorizeEmail(String email) async {
    final json = await lanternFFI
        .approveDevice(email.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    final result = BaseResponse.create()..mergeFromProto3Json(jsonDecode(json));
    return json;
  }

  Future<String> userLinkValidate(String code) async {
    final json = await lanternFFI
        .userLinkValidate(code.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    checkAPIError(json, "invalid_code".i18n);
    return json;
  }

  FutureOr<bool> hasPlanUpdateOrBuy(dynamic context) {
    final json = lanternFFI.hasPlanUpdatedOrBuy().cast<Utf8>().toDartString();
    return json == 'true' ? true : throw NoPlansUpdate("No Plans update");
  }

  Pointer<Utf8> devices() => lanternFFI.devices().cast<Utf8>();

  Pointer<Utf8> developmentMode() => lanternFFI.developmentMode().cast<Utf8>();

  Pointer<Utf8> acceptedTermsVersion() =>
      lanternFFI.acceptedTermsVersion().cast<Utf8>();

  Pointer<Utf8> emailAddress() => lanternFFI.emailAddress().cast<Utf8>();

  Future<String> emailExists(String email) async => await lanternFFI
      .emailExists(email.toPointerChar())
      .cast<Utf8>()
      .toDartString();

  Future<void> redeemResellerCode(List<String> params) {
    final email = params[0].toPointerChar();
    final currency = params[1].toPointerChar();
    final deviceName = params[2].toPointerChar();
    final resellerCode = params[3].toPointerChar();
    final result = lanternFFI
        .redeemResellerCode(email, currency, deviceName, resellerCode)
        .cast<Utf8>()
        .toDartString();
    checkAPIError(result, 'wrong_seller_code'.i18n);
    return Future.value();
  }

  Pointer<Utf8> referral() => lanternFFI.referral().cast<Utf8>();

  Pointer<Utf8> deviceId() => lanternFFI.myDeviceId().cast<Utf8>();

  Pointer<Utf8> replicaAddr() => lanternFFI.replicaAddr().cast<Utf8>();

  Pointer<Utf8> chatEnabled() => lanternFFI.chatEnabled().cast<Utf8>();

  Pointer<Utf8> authEnabled() => lanternFFI.authEnabled().cast<Utf8>();

  Pointer<Utf8> sdkVersion() => lanternFFI.sdkVersion().cast<Utf8>();

  Pointer<Utf8> checkUpdates() => lanternFFI.checkUpdates().cast<Utf8>();

  Pointer<Utf8> plans() => lanternFFI.plans().cast<Utf8>();

  Pointer<Utf8> paymentMethods() => lanternFFI.paymentMethodsV3().cast<Utf8>();

  Pointer<Utf8> paymentMethodsV4() =>
      lanternFFI.paymentMethodsV4().cast<Utf8>();

  Pointer<Utf8> deviceLinkingCode() =>
      lanternFFI.deviceLinkingCode().cast<Utf8>();

  Pointer<Utf8> expiryDate() => lanternFFI.expiryDate().cast<Utf8>();

  Pointer<Utf8> splitTunneling() => lanternFFI.splitTunneling().cast<Utf8>();

  Pointer<Utf8> chatMe() => lanternFFI.chatMe().cast<Utf8>();

  Pointer<Utf8> onBoardingStatus() =>
      lanternFFI.onBoardingStatus().cast<Utf8>();

  Pointer<Utf8> serverInfo() => lanternFFI.serverInfo().cast<Utf8>();

  Future<void> reportIssue(List<String> list) {
    final email = list[0].toPointerChar();
    final issueType = list[1].toPointerChar();
    final description = list[2].toPointerChar();
    final result = lanternFFI
        .reportIssue(email, issueType, description)
        .cast<Utf8>()
        .toDartString();

    checkAPIError(result, 'we_are_experiencing_technical_difficulties'.i18n);
    return Future.value();
  }

  Future<String> paymentRedirect(List<String> list) {
    final planID = list[0].toPointerChar();
    final currency = list[1].toPointerChar();
    final provider = list[2].toPointerChar();
    final email = list[3].toPointerChar();
    final deviceName = list[4].toPointerChar();
    final json = lanternFFI
        .paymentRedirect(planID, currency, provider, email, deviceName)
        .cast<Utf8>()
        .toDartString();
    final result = PaymentRedirectResponse.create()
      ..mergeFromProto3Json(jsonDecode(json));
    checkAPIError(result, 'we_are_experiencing_technical_difficulties'.i18n);
    return Future.value(result.redirect);
  }

  Future<void> testPaymentRequest(List<String> params) {
    final email = params[0].toPointerChar();
    final paymentProvider = params[1].toPointerChar();
    final planId = params[2].toPointerChar();
    final result = lanternFFI
        .testProviderRequest(email, paymentProvider, planId)
        .cast<Utf8>()
        .toDartString();
    checkAuthAPIError(result);
    return Future.value();
  }

  /// Auth methods for desktop

  /// FFI pointer to the native function
  Pointer<Utf8> isUserLoggedIn() {
    final result = lanternFFI.isUserLoggedIn().cast<Utf8>();
    print(result.toDartString());
    return result;
  }

  /// FFI function
  Future<bool> userFirstVisit() {
    final result = lanternFFI.isUserFirstTime().cast<Utf8>().toDartString();
    return Future.value(result == 'true');
  }

  void setUserFirstTimeVisit() => lanternFFI.setFirstTimeVisit();

  ///signup
  Future<void> signUp(List<String> params) {
    final email = params[0].toPointerChar();
    final password = params[1].toPointerChar();
    final result = lanternFFI.signup(email, password).cast<Utf8>().toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  /// login
  Future<void> login(List<String> params) {
    final email = params[0].toPointerChar();
    final password = params[1].toPointerChar();
    final result = lanternFFI.login(email, password).cast<Utf8>().toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  /// logout
  Future<void> logout(dynamic context) {
    final result = lanternFFI.logout().cast<Utf8>().toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  /// start recovery by email
  /// send verification code to email
  Future<void> startRecoveryByEmail(String email) {
    final result = lanternFFI
        .startRecoveryByEmail(email.toPointerChar())
        .cast<Utf8>()
        .toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  /// start recovery by email
  /// send verification code to email
  Future<void> validateRecoveryByEmail(List<String> params) {
    final email = params[0].toPointerChar();
    final code = params[1].toPointerChar();
    final result = lanternFFI
        .validateRecoveryByEmail(email, code)
        .cast<Utf8>()
        .toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  Future<void> completeRecoveryByEmail(List<String> params) {
    final email = params[0].toPointerChar();
    final password = params[1].toPointerChar();
    final code = params[2].toPointerChar();
    final result = lanternFFI
        .completeRecoveryByEmail(email, code, password)
        .cast<Utf8>()
        .toDartString();
    checkAuthAPIError(result);
    return Future.value(result.toBool());
  }

  Future<void> deleteAccount(String password) {
    final result = lanternFFI
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

final lanternFFI = LanternFFI();
