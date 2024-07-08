// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_field
// ignore_for_file: unused_element

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Bindings to `liblantern.h`.
class NativeLibrary {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibrary(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibrary.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void start() {
    return _start();
  }

  late final _startPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('start');
  late final _start = _startPtr.asFunction<void Function()>();

  ffi.Pointer<ffi.Char> hasProxyFected() {
    return _hasProxyFected();
  }

  late final _hasProxyFectedPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'hasProxyFected');
  late final _hasProxyFected =
      _hasProxyFectedPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> hasConfigFected() {
    return _hasConfigFected();
  }

  late final _hasConfigFectedPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'hasConfigFected');
  late final _hasConfigFected =
      _hasConfigFectedPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> onSuccess() {
    return _onSuccess();
  }

  late final _onSuccessPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'onSuccess');
  late final _onSuccess =
      _onSuccessPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  void sysProxyOn() {
    return _sysProxyOn();
  }

  late final _sysProxyOnPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('sysProxyOn');
  late final _sysProxyOn = _sysProxyOnPtr.asFunction<void Function()>();

  void sysProxyOff() {
    return _sysProxyOff();
  }

  late final _sysProxyOffPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('sysProxyOff');
  late final _sysProxyOff = _sysProxyOffPtr.asFunction<void Function()>();

  ffi.Pointer<ffi.Char> websocketAddr() {
    return _websocketAddr();
  }

  late final _websocketAddrPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'websocketAddr');
  late final _websocketAddr =
      _websocketAddrPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> plans() {
    return _plans();
  }

  late final _plansPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('plans');
  late final _plans = _plansPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> paymentMethodsV3() {
    return _paymentMethodsV3();
  }

  late final _paymentMethodsV3Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'paymentMethodsV3');
  late final _paymentMethodsV3 =
      _paymentMethodsV3Ptr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> paymentMethodsV4() {
    return _paymentMethodsV4();
  }

  late final _paymentMethodsV4Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'paymentMethodsV4');
  late final _paymentMethodsV4 =
      _paymentMethodsV4Ptr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> proxyAll() {
    return _proxyAll();
  }

  late final _proxyAllPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('proxyAll');
  late final _proxyAll =
      _proxyAllPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  void setProxyAll(
    ffi.Pointer<ffi.Char> value,
  ) {
    return _setProxyAll(
      value,
    );
  }

  late final _setProxyAllPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>(
          'setProxyAll');
  late final _setProxyAll =
      _setProxyAllPtr.asFunction<void Function(ffi.Pointer<ffi.Char>)>();

  /// this method is reposible for checking if the user has updated plan or bought plans
  ffi.Pointer<ffi.Char> hasPlanUpdatedOrBuy() {
    return _hasPlanUpdatedOrBuy();
  }

  late final _hasPlanUpdatedOrBuyPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'hasPlanUpdatedOrBuy');
  late final _hasPlanUpdatedOrBuy =
      _hasPlanUpdatedOrBuyPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> devices() {
    return _devices();
  }

  late final _devicesPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('devices');
  late final _devices =
      _devicesPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> approveDevice(
    ffi.Pointer<ffi.Char> code,
  ) {
    return _approveDevice(
      code,
    );
  }

  late final _approveDevicePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>)>>('approveDevice');
  late final _approveDevice = _approveDevicePtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> removeDevice(
    ffi.Pointer<ffi.Char> deviceId,
  ) {
    return _removeDevice(
      deviceId,
    );
  }

  late final _removeDevicePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>)>>('removeDevice');
  late final _removeDevice = _removeDevicePtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> expiryDate() {
    return _expiryDate();
  }

  late final _expiryDatePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'expiryDate');
  late final _expiryDate =
      _expiryDatePtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> userData() {
    return _userData();
  }

  late final _userDataPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('userData');
  late final _userData =
      _userDataPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> serverInfo() {
    return _serverInfo();
  }

  late final _serverInfoPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'serverInfo');
  late final _serverInfo =
      _serverInfoPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> emailAddress() {
    return _emailAddress();
  }

  late final _emailAddressPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'emailAddress');
  late final _emailAddress =
      _emailAddressPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> emailExists(
    ffi.Pointer<ffi.Char> email,
  ) {
    return _emailExists(
      email,
    );
  }

  late final _emailExistsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>)>>('emailExists');
  late final _emailExists = _emailExistsPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> testProviderRequest(
    ffi.Pointer<ffi.Char> email,
    ffi.Pointer<ffi.Char> paymentProvider,
    ffi.Pointer<ffi.Char> plan,
  ) {
    return _testProviderRequest(
      email,
      paymentProvider,
      plan,
    );
  }

  late final _testProviderRequestPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('testProviderRequest');
  late final _testProviderRequest = _testProviderRequestPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  /// The function returns two C strings: the first represents success, and the second represents an error.
  /// If the redemption is successful, the first string contains "true", and the second string is nil.
  /// If an error occurs during redemption, the first string is nil, and the second string contains the error message.
  ffi.Pointer<ffi.Char> redeemResellerCode(
    ffi.Pointer<ffi.Char> email,
    ffi.Pointer<ffi.Char> currency,
    ffi.Pointer<ffi.Char> deviceName,
    ffi.Pointer<ffi.Char> resellerCode,
  ) {
    return _redeemResellerCode(
      email,
      currency,
      deviceName,
      resellerCode,
    );
  }

  late final _redeemResellerCodePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('redeemResellerCode');
  late final _redeemResellerCode = _redeemResellerCodePtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> referral() {
    return _referral();
  }

  late final _referralPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('referral');
  late final _referral =
      _referralPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> myDeviceId() {
    return _myDeviceId();
  }

  late final _myDeviceIdPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'myDeviceId');
  late final _myDeviceId =
      _myDeviceIdPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> chatEnabled() {
    return _chatEnabled();
  }

  late final _chatEnabledPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'chatEnabled');
  late final _chatEnabled =
      _chatEnabledPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> playVersion() {
    return _playVersion();
  }

  late final _playVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'playVersion');
  late final _playVersion =
      _playVersionPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> storeVersion() {
    return _storeVersion();
  }

  late final _storeVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'storeVersion');
  late final _storeVersion =
      _storeVersionPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> lang() {
    return _lang();
  }

  late final _langPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('lang');
  late final _lang = _langPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  void setSelectLang(
    ffi.Pointer<ffi.Char> lang,
  ) {
    return _setSelectLang(
      lang,
    );
  }

  late final _setSelectLangPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>(
          'setSelectLang');
  late final _setSelectLang =
      _setSelectLangPtr.asFunction<void Function(ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> country() {
    return _country();
  }

  late final _countryPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('country');
  late final _country =
      _countryPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> sdkVersion() {
    return _sdkVersion();
  }

  late final _sdkVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'sdkVersion');
  late final _sdkVersion =
      _sdkVersionPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> vpnStatus() {
    return _vpnStatus();
  }

  late final _vpnStatusPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'vpnStatus');
  late final _vpnStatus =
      _vpnStatusPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> hasSucceedingProxy() {
    return _hasSucceedingProxy();
  }

  late final _hasSucceedingProxyPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'hasSucceedingProxy');
  late final _hasSucceedingProxy =
      _hasSucceedingProxyPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> onBoardingStatus() {
    return _onBoardingStatus();
  }

  late final _onBoardingStatusPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'onBoardingStatus');
  late final _onBoardingStatus =
      _onBoardingStatusPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> acceptedTermsVersion() {
    return _acceptedTermsVersion();
  }

  late final _acceptedTermsVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'acceptedTermsVersion');
  late final _acceptedTermsVersion =
      _acceptedTermsVersionPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> proUser() {
    return _proUser();
  }

  late final _proUserPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('proUser');
  late final _proUser =
      _proUserPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> deviceLinkingCode() {
    return _deviceLinkingCode();
  }

  late final _deviceLinkingCodePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'deviceLinkingCode');
  late final _deviceLinkingCode =
      _deviceLinkingCodePtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> paymentRedirect(
    ffi.Pointer<ffi.Char> planID,
    ffi.Pointer<ffi.Char> currency,
    ffi.Pointer<ffi.Char> provider,
    ffi.Pointer<ffi.Char> email,
    ffi.Pointer<ffi.Char> deviceName,
  ) {
    return _paymentRedirect(
      planID,
      currency,
      provider,
      email,
      deviceName,
    );
  }

  late final _paymentRedirectPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('paymentRedirect');
  late final _paymentRedirect = _paymentRedirectPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>)>();

  void exitApp() {
    return _exitApp();
  }

  late final _exitAppPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('exitApp');
  late final _exitApp = _exitAppPtr.asFunction<void Function()>();

  ffi.Pointer<ffi.Char> developmentMode() {
    return _developmentMode();
  }

  late final _developmentModePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'developmentMode');
  late final _developmentMode =
      _developmentModePtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> splitTunneling() {
    return _splitTunneling();
  }

  late final _splitTunnelingPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'splitTunneling');
  late final _splitTunneling =
      _splitTunnelingPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> chatMe() {
    return _chatMe();
  }

  late final _chatMePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('chatMe');
  late final _chatMe =
      _chatMePtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> replicaAddr() {
    return _replicaAddr();
  }

  late final _replicaAddrPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'replicaAddr');
  late final _replicaAddr =
      _replicaAddrPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  reportIssue_return reportIssue(
    ffi.Pointer<ffi.Char> email,
    ffi.Pointer<ffi.Char> issueType,
    ffi.Pointer<ffi.Char> description,
  ) {
    return _reportIssue(
      email,
      issueType,
      description,
    );
  }

  late final _reportIssuePtr = _lookup<
      ffi.NativeFunction<
          reportIssue_return Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>>('reportIssue');
  late final _reportIssue = _reportIssuePtr.asFunction<
      reportIssue_return Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> checkUpdates() {
    return _checkUpdates();
  }

  late final _checkUpdatesPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'checkUpdates');
  late final _checkUpdates =
      _checkUpdatesPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> isUserFirstTime() {
    return _isUserFirstTime();
  }

  late final _isUserFirstTimePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'isUserFirstTime');
  late final _isUserFirstTime =
      _isUserFirstTimePtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  void setFirstTimeVisit() {
    return _setFirstTimeVisit();
  }

  late final _setFirstTimeVisitPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('setFirstTimeVisit');
  late final _setFirstTimeVisit =
      _setFirstTimeVisitPtr.asFunction<void Function()>();

  ffi.Pointer<ffi.Char> isUserLoggedIn() {
    return _isUserLoggedIn();
  }

  late final _isUserLoggedInPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'isUserLoggedIn');
  late final _isUserLoggedIn =
      _isUserLoggedInPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> signup(
    ffi.Pointer<ffi.Char> email,
    ffi.Pointer<ffi.Char> password,
  ) {
    return _signup(
      email,
      password,
    );
  }

  late final _signupPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>>('signup');
  late final _signup = _signupPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> login(
    ffi.Pointer<ffi.Char> email,
    ffi.Pointer<ffi.Char> password,
  ) {
    return _login(
      email,
      password,
    );
  }

  late final _loginPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>>('login');
  late final _login = _loginPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> logout() {
    return _logout();
  }

  late final _logoutPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('logout');
  late final _logout =
      _logoutPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  /// Send recovery code to user email
  ffi.Pointer<ffi.Char> startRecoveryByEmail(
    ffi.Pointer<ffi.Char> email,
  ) {
    return _startRecoveryByEmail(
      email,
    );
  }

  late final _startRecoveryByEmailPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>)>>('startRecoveryByEmail');
  late final _startRecoveryByEmail = _startRecoveryByEmailPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  /// Complete recovery by email
  ffi.Pointer<ffi.Char> completeRecoveryByEmail(
    ffi.Pointer<ffi.Char> email,
    ffi.Pointer<ffi.Char> code,
    ffi.Pointer<ffi.Char> password,
  ) {
    return _completeRecoveryByEmail(
      email,
      code,
      password,
    );
  }

  late final _completeRecoveryByEmailPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('completeRecoveryByEmail');
  late final _completeRecoveryByEmail = _completeRecoveryByEmailPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  /// // This will validate code send by server
  ffi.Pointer<ffi.Char> validateRecoveryByEmail(
    ffi.Pointer<ffi.Char> email,
    ffi.Pointer<ffi.Char> code,
  ) {
    return _validateRecoveryByEmail(
      email,
      code,
    );
  }

  late final _validateRecoveryByEmailPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('validateRecoveryByEmail');
  late final _validateRecoveryByEmail = _validateRecoveryByEmailPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  /// This will delete user accoutn and creates new user
  ffi.Pointer<ffi.Char> deleteAccount(
    ffi.Pointer<ffi.Char> password,
  ) {
    return _deleteAccount(
      password,
    );
  }

  late final _deleteAccountPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>)>>('deleteAccount');
  late final _deleteAccount = _deleteAccountPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();
}

/// mbstate_t is an opaque object to keep conversion state, during multibyte
/// stream conversions.  The content must not be referenced by user programs.
final class __mbstate_t extends ffi.Union {
  @ffi.Array.multi([128])
  external ffi.Array<ffi.Char> __mbstate8;

  /// for alignment
  @ffi.LongLong()
  external int _mbstateL;
}

final class __darwin_pthread_handler_rec extends ffi.Struct {
  /// Routine to call
  external ffi
      .Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>
      __routine;

  /// Argument to pass
  external ffi.Pointer<ffi.Void> __arg;

  external ffi.Pointer<__darwin_pthread_handler_rec> __next;
}

final class _opaque_pthread_attr_t extends ffi.Struct {
  @ffi.Long()
  external int __sig;

  @ffi.Array.multi([56])
  external ffi.Array<ffi.Char> __opaque;
}

final class _opaque_pthread_cond_t extends ffi.Struct {
  @ffi.Long()
  external int __sig;

  @ffi.Array.multi([40])
  external ffi.Array<ffi.Char> __opaque;
}

final class _opaque_pthread_condattr_t extends ffi.Struct {
  @ffi.Long()
  external int __sig;

  @ffi.Array.multi([8])
  external ffi.Array<ffi.Char> __opaque;
}

final class _opaque_pthread_mutex_t extends ffi.Struct {
  @ffi.Long()
  external int __sig;

  @ffi.Array.multi([56])
  external ffi.Array<ffi.Char> __opaque;
}

final class _opaque_pthread_mutexattr_t extends ffi.Struct {
  @ffi.Long()
  external int __sig;

  @ffi.Array.multi([8])
  external ffi.Array<ffi.Char> __opaque;
}

final class _opaque_pthread_once_t extends ffi.Struct {
  @ffi.Long()
  external int __sig;

  @ffi.Array.multi([8])
  external ffi.Array<ffi.Char> __opaque;
}

final class _opaque_pthread_rwlock_t extends ffi.Struct {
  @ffi.Long()
  external int __sig;

  @ffi.Array.multi([192])
  external ffi.Array<ffi.Char> __opaque;
}

final class _opaque_pthread_rwlockattr_t extends ffi.Struct {
  @ffi.Long()
  external int __sig;

  @ffi.Array.multi([16])
  external ffi.Array<ffi.Char> __opaque;
}

final class _opaque_pthread_t extends ffi.Struct {
  @ffi.Long()
  external int __sig;

  external ffi.Pointer<__darwin_pthread_handler_rec> __cleanup_stack;

  @ffi.Array.multi([8176])
  external ffi.Array<ffi.Char> __opaque;
}

final class _GoString_ extends ffi.Struct {
  external ffi.Pointer<ffi.Char> p;

  @ptrdiff_t()
  external int n;
}

typedef ptrdiff_t = __darwin_ptrdiff_t;
typedef __darwin_ptrdiff_t = ffi.Long;
typedef Dart__darwin_ptrdiff_t = int;

final class GoInterface extends ffi.Struct {
  external ffi.Pointer<ffi.Void> t;

  external ffi.Pointer<ffi.Void> v;
}

final class GoSlice extends ffi.Struct {
  external ffi.Pointer<ffi.Void> data;

  @GoInt()
  external int len;

  @GoInt()
  external int cap;
}

typedef GoInt = GoInt64;
typedef GoInt64 = ffi.LongLong;
typedef DartGoInt64 = int;

/// Return type for reportIssue
final class reportIssue_return extends ffi.Struct {
  external ffi.Pointer<ffi.Char> r0;

  external ffi.Pointer<ffi.Char> r1;
}

const int __has_safe_buffers = 1;

const int __DARWIN_ONLY_64_BIT_INO_T = 1;

const int __DARWIN_ONLY_UNIX_CONFORMANCE = 1;

const int __DARWIN_ONLY_VERS_1050 = 1;

const int __DARWIN_UNIX03 = 1;

const int __DARWIN_64_BIT_INO_T = 1;

const int __DARWIN_VERS_1050 = 1;

const int __DARWIN_NON_CANCELABLE = 0;

const String __DARWIN_SUF_EXTSN = '\$DARWIN_EXTSN';

const int __DARWIN_C_ANSI = 4096;

const int __DARWIN_C_FULL = 900000;

const int __DARWIN_C_LEVEL = 900000;

const int __STDC_WANT_LIB_EXT1__ = 1;

const int __DARWIN_NO_LONG_LONG = 0;

const int _DARWIN_FEATURE_64_BIT_INODE = 1;

const int _DARWIN_FEATURE_ONLY_64_BIT_INODE = 1;

const int _DARWIN_FEATURE_ONLY_VERS_1050 = 1;

const int _DARWIN_FEATURE_ONLY_UNIX_CONFORMANCE = 1;

const int _DARWIN_FEATURE_UNIX_CONFORMANCE = 3;

const int __has_ptrcheck = 0;

const int __DARWIN_NULL = 0;

const int __PTHREAD_SIZE__ = 8176;

const int __PTHREAD_ATTR_SIZE__ = 56;

const int __PTHREAD_MUTEXATTR_SIZE__ = 8;

const int __PTHREAD_MUTEX_SIZE__ = 56;

const int __PTHREAD_CONDATTR_SIZE__ = 8;

const int __PTHREAD_COND_SIZE__ = 40;

const int __PTHREAD_ONCE_SIZE__ = 8;

const int __PTHREAD_RWLOCK_SIZE__ = 192;

const int __PTHREAD_RWLOCKATTR_SIZE__ = 16;

const int __DARWIN_WCHAR_MAX = 2147483647;

const int __DARWIN_WCHAR_MIN = -2147483648;

const int __DARWIN_WEOF = -1;

const int _FORTIFY_SOURCE = 2;

const int NULL = 0;

const int USER_ADDR_NULL = 0;
