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

  ffi.Pointer<ffi.Char> start() {
    return _start();
  }

  late final _startPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>('start');
  late final _start = _startPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> sysProxyOn() {
    return _sysProxyOn();
  }

  late final _sysProxyOnPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'sysProxyOn');
  late final _sysProxyOn =
      _sysProxyOnPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

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

  ffi.Pointer<ffi.Char> applyRef(
    ffi.Pointer<ffi.Char> referralCode,
  ) {
    return _applyRef(
      referralCode,
    );
  }

  late final _applyRefPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('applyRef');
  late final _applyRef = _applyRefPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

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

  ffi.Pointer<ffi.Char> userLinkCode(
    ffi.Pointer<ffi.Char> email,
  ) {
    return _userLinkCode(
      email,
    );
  }

  late final _userLinkCodePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>)>>('userLinkCode');
  late final _userLinkCode = _userLinkCodePtr
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

  ffi.Pointer<ffi.Char> userLinkValidate(
    ffi.Pointer<ffi.Char> code,
  ) {
    return _userLinkValidate(
      code,
    );
  }

  late final _userLinkValidatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>)>>('userLinkValidate');
  late final _userLinkValidate = _userLinkValidatePtr
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

  ffi.Pointer<ffi.Char> reportIssue(
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
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>>('reportIssue');
  late final _reportIssue = _reportIssuePtr.asFunction<
      ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> updatePaymentMethod() {
    return _updatePaymentMethod();
  }

  late final _updatePaymentMethodPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'updatePaymentMethod');
  late final _updatePaymentMethod =
      _updatePaymentMethodPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> checkUpdates() {
    return _checkUpdates();
  }

  late final _checkUpdatesPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'checkUpdates');
  late final _checkUpdates =
      _checkUpdatesPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();
}

typedef __int8_t = ffi.SignedChar;
typedef Dart__int8_t = int;
typedef __uint8_t = ffi.UnsignedChar;
typedef Dart__uint8_t = int;
typedef __int16_t = ffi.Short;
typedef Dart__int16_t = int;
typedef __uint16_t = ffi.UnsignedShort;
typedef Dart__uint16_t = int;
typedef __int32_t = ffi.Int;
typedef Dart__int32_t = int;
typedef __uint32_t = ffi.UnsignedInt;
typedef Dart__uint32_t = int;
typedef __int64_t = ffi.LongLong;
typedef Dart__int64_t = int;
typedef __uint64_t = ffi.UnsignedLongLong;
typedef Dart__uint64_t = int;
typedef __darwin_intptr_t = ffi.Long;
typedef Dart__darwin_intptr_t = int;
typedef __darwin_natural_t = ffi.UnsignedInt;
typedef Dart__darwin_natural_t = int;

/// The rune type below is declared to be an ``int'' instead of the more natural
/// ``unsigned long'' or ``long''.  Two things are happening here.  It is not
/// unsigned so that EOF (-1) can be naturally assigned to it and used.  Also,
/// it looks like 10646 will be a 31 bit standard.  This means that if your
/// ints cannot hold 32 bits, you will be in trouble.  The reason an int was
/// chosen over a long is that the is*() and to*() routines take ints (says
/// ANSI C), but they use __darwin_ct_rune_t instead of int.  By changing it
/// here, you lose a bit of ANSI conformance, but your programs will still
/// work.
///
/// NOTE: rune_t is not covered by ANSI nor other standards, and should not
/// be instantiated outside of lib/libc/locale.  Use wchar_t.  wchar_t and
/// rune_t must be the same type.  Also wint_t must be no narrower than
/// wchar_t, and should also be able to hold all members of the largest
/// character set plus one extra value (WEOF). wint_t must be at least 16 bits.
typedef __darwin_ct_rune_t = ffi.Int;
typedef Dart__darwin_ct_rune_t = int;

/// mbstate_t is an opaque object to keep conversion state, during multibyte
/// stream conversions.  The content must not be referenced by user programs.
final class __mbstate_t extends ffi.Union {
  @ffi.Array.multi([128])
  external ffi.Array<ffi.Char> __mbstate8;

  /// for alignment
  @ffi.LongLong()
  external int _mbstateL;
}

typedef __darwin_mbstate_t = __mbstate_t;
typedef __darwin_ptrdiff_t = ffi.Long;
typedef Dart__darwin_ptrdiff_t = int;
typedef __darwin_size_t = ffi.UnsignedLong;
typedef Dart__darwin_size_t = int;
typedef __builtin_va_list = ffi.Pointer<ffi.Char>;
typedef __darwin_va_list = __builtin_va_list;
typedef __darwin_wchar_t = ffi.Int;
typedef Dart__darwin_wchar_t = int;
typedef __darwin_rune_t = __darwin_wchar_t;
typedef __darwin_wint_t = ffi.Int;
typedef Dart__darwin_wint_t = int;
typedef __darwin_clock_t = ffi.UnsignedLong;
typedef Dart__darwin_clock_t = int;
typedef __darwin_socklen_t = __uint32_t;
typedef __darwin_ssize_t = ffi.Long;
typedef Dart__darwin_ssize_t = int;
typedef __darwin_time_t = ffi.Long;
typedef Dart__darwin_time_t = int;
typedef __darwin_blkcnt_t = __int64_t;
typedef __darwin_blksize_t = __int32_t;
typedef __darwin_dev_t = __int32_t;
typedef __darwin_fsblkcnt_t = ffi.UnsignedInt;
typedef Dart__darwin_fsblkcnt_t = int;
typedef __darwin_fsfilcnt_t = ffi.UnsignedInt;
typedef Dart__darwin_fsfilcnt_t = int;
typedef __darwin_gid_t = __uint32_t;
typedef __darwin_id_t = __uint32_t;
typedef __darwin_ino64_t = __uint64_t;
typedef __darwin_ino_t = __darwin_ino64_t;
typedef __darwin_mach_port_name_t = __darwin_natural_t;
typedef __darwin_mach_port_t = __darwin_mach_port_name_t;
typedef __darwin_mode_t = __uint16_t;
typedef __darwin_off_t = __int64_t;
typedef __darwin_pid_t = __int32_t;
typedef __darwin_sigset_t = __uint32_t;
typedef __darwin_suseconds_t = __int32_t;
typedef __darwin_uid_t = __uint32_t;
typedef __darwin_useconds_t = __uint32_t;

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

typedef __darwin_pthread_attr_t = _opaque_pthread_attr_t;
typedef __darwin_pthread_cond_t = _opaque_pthread_cond_t;
typedef __darwin_pthread_condattr_t = _opaque_pthread_condattr_t;
typedef __darwin_pthread_key_t = ffi.UnsignedLong;
typedef Dart__darwin_pthread_key_t = int;
typedef __darwin_pthread_mutex_t = _opaque_pthread_mutex_t;
typedef __darwin_pthread_mutexattr_t = _opaque_pthread_mutexattr_t;
typedef __darwin_pthread_once_t = _opaque_pthread_once_t;
typedef __darwin_pthread_rwlock_t = _opaque_pthread_rwlock_t;
typedef __darwin_pthread_rwlockattr_t = _opaque_pthread_rwlockattr_t;
typedef __darwin_pthread_t = ffi.Pointer<_opaque_pthread_t>;
typedef __darwin_nl_item = ffi.Int;
typedef Dart__darwin_nl_item = int;
typedef __darwin_wctrans_t = ffi.Int;
typedef Dart__darwin_wctrans_t = int;
typedef __darwin_wctype_t = __uint32_t;
typedef u_int8_t = ffi.UnsignedChar;
typedef Dartu_int8_t = int;
typedef u_int16_t = ffi.UnsignedShort;
typedef Dartu_int16_t = int;
typedef u_int32_t = ffi.UnsignedInt;
typedef Dartu_int32_t = int;
typedef u_int64_t = ffi.UnsignedLongLong;
typedef Dartu_int64_t = int;
typedef register_t = ffi.Int64;
typedef Dartregister_t = int;
typedef user_addr_t = u_int64_t;
typedef user_size_t = u_int64_t;
typedef user_ssize_t = ffi.Int64;
typedef Dartuser_ssize_t = int;
typedef user_long_t = ffi.Int64;
typedef Dartuser_long_t = int;
typedef user_ulong_t = u_int64_t;
typedef user_time_t = ffi.Int64;
typedef Dartuser_time_t = int;
typedef user_off_t = ffi.Int64;
typedef Dartuser_off_t = int;
typedef syscall_arg_t = u_int64_t;
typedef ptrdiff_t = __darwin_ptrdiff_t;
typedef rsize_t = __darwin_size_t;
typedef wint_t = __darwin_wint_t;

final class _GoString_ extends ffi.Struct {
  external ffi.Pointer<ffi.Char> p;

  @ptrdiff_t()
  external int n;
}

typedef GoInt8 = ffi.SignedChar;
typedef DartGoInt8 = int;
typedef GoUint8 = ffi.UnsignedChar;
typedef DartGoUint8 = int;
typedef GoInt16 = ffi.Short;
typedef DartGoInt16 = int;
typedef GoUint16 = ffi.UnsignedShort;
typedef DartGoUint16 = int;
typedef GoInt32 = ffi.Int;
typedef DartGoInt32 = int;
typedef GoUint32 = ffi.UnsignedInt;
typedef DartGoUint32 = int;
typedef GoInt64 = ffi.LongLong;
typedef DartGoInt64 = int;
typedef GoUint64 = ffi.UnsignedLongLong;
typedef DartGoUint64 = int;
typedef GoInt = GoInt64;
typedef GoUint = GoUint64;
typedef GoUintptr = ffi.Size;
typedef DartGoUintptr = int;
typedef GoFloat32 = ffi.Float;
typedef DartGoFloat32 = double;
typedef GoFloat64 = ffi.Double;
typedef DartGoFloat64 = double;
typedef GoString = _GoString_;
typedef GoMap = ffi.Pointer<ffi.Void>;
typedef GoChan = ffi.Pointer<ffi.Void>;

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

typedef GoInt81 = ffi.SignedChar;
typedef DartGoInt81 = int;
typedef GoUint81 = ffi.UnsignedChar;
typedef DartGoUint81 = int;
typedef GoInt161 = ffi.Short;
typedef DartGoInt161 = int;
typedef GoUint161 = ffi.UnsignedShort;
typedef DartGoUint161 = int;
typedef GoInt321 = ffi.Int;
typedef DartGoInt321 = int;
typedef GoUint321 = ffi.UnsignedInt;
typedef DartGoUint321 = int;
typedef GoInt641 = ffi.LongLong;
typedef DartGoInt641 = int;
typedef GoUint641 = ffi.UnsignedLongLong;
typedef DartGoUint641 = int;
typedef GoInt1 = GoInt641;
typedef GoUint1 = GoUint641;
typedef GoUintptr1 = ffi.Size;
typedef DartGoUintptr1 = int;
typedef GoFloat321 = ffi.Float;
typedef DartGoFloat321 = double;
typedef GoFloat641 = ffi.Double;
typedef DartGoFloat641 = double;
typedef GoString1 = _GoString_;
typedef GoMap1 = ffi.Pointer<ffi.Void>;
typedef GoChan1 = ffi.Pointer<ffi.Void>;

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
