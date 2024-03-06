import 'package:lantern/replica/common.dart';

import 'common.dart';

final sessionModel = SessionModel();

const TAB_CHATS = 'chats';
const TAB_VPN = 'vpn';
const TAB_REPLICA = 'discover';
const TAB_ACCOUNT = 'account';
const TAB_DEVELOPER = 'developer';

class SessionModel extends Model {
  late final EventManager eventManager;

  ValueNotifier<bool> networkAvailable = ValueNotifier(true);
  late ValueNotifier<bool?> isPlayVersion;
  late ValueNotifier<bool?> isStoreVersion;
  late ValueNotifier<bool?> proxyAvailable;
  late ValueNotifier<bool?> hasAccountVerified;
  late ValueNotifier<bool?> proUserNotifier;
  late ValueNotifier<String?> country;
  late ValueNotifier<String?> userEmail;
  late ValueNotifier<bool?> hasUserSignedInNotifier;
  late ValueNotifier<String?> deviceIdNotifier;

  SessionModel() : super('session') {
    eventManager = EventManager('lantern_event_channel');
    eventManager.subscribe(Event.All, (eventType, map) {
      switch (eventType) {
        case Event.NoNetworkAvailable:
          networkAvailable.value = false;
          break;
        case Event.NetworkAvailable:
          networkAvailable.value = true;
          break;
        default:
          break;
      }
    });

    isStoreVersion = singleValueNotifier(
      'storeVersion',
      false,
    );
    isPlayVersion = singleValueNotifier(
      'playVersion',
      false,
    );
    userEmail = singleValueNotifier(
      'emailAddress',
      "",
    );

    /*Note
    * Make proxyAvailable default value to true on IOS it take some to get data from go side
    * So show banner only if proxyAvailable is false
    */
    proxyAvailable = singleValueNotifier('hasSucceedingProxy', true);
    country = singleValueNotifier('geo_country_code', 'US');

    /// This warning is not needed for the Non pro user
    /// This flow is not needed anymore
    /// We don't user create account if email address is not verified
    hasAccountVerified = ValueNotifier(true);
    hasUserSignedInNotifier = singleValueNotifier('IsUserLoggedIn', false);
    proUserNotifier = singleValueNotifier('prouser', false);
    deviceIdNotifier = singleValueNotifier('deviceid', "");
  }

  Widget proUser(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('prouser', builder: builder);
  }

  Widget developmentMode(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>(
      'developmentMode',
      builder: builder,
    );
  }

  Widget paymentTestMode(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>(
      'paymentTestMode',
      builder: builder,
    );
  }

  Future<void> setPaymentTestMode(bool on) {
    return methodChannel.invokeMethod('setPaymentTestMode', <String, dynamic>{
      'on': on,
    });
  }

  Future<void> acceptTerms() {
    return methodChannel.invokeMethod('acceptTerms', <String, dynamic>{
      'on': true,
    });
  }

  Widget acceptedTermsVersion(ValueWidgetBuilder<int> builder) {
    return subscribedSingleValueBuilder<int>('accepted_terms_version',
        builder: builder, defaultValue: 0);
  }

  Widget forceCountry(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'forceCountry',
      builder: builder,
    );
  }

  Future<void> setForceCountry(String? countryCode) {
    return methodChannel.invokeMethod('setForceCountry', <String, dynamic>{
      'countryCode': countryCode,
    });
  }

  Widget geoCountryCode(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'geo_country_code',
      builder: builder,
    );
  }

  Widget playVersion(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('playVersion', builder: builder);
  }

  Future<void> setPlayVersion(bool on) {
    return methodChannel.invokeMethod('setPlayVersion', <String, dynamic>{
      'on': on,
    });
  }

  Widget language(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('lang', builder: builder);
  }

  Widget emailAddress(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'emailAddress',
      builder: builder,
    );
  }

  Widget expiryDate(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'expirydatestr',
      builder: builder,
    );
  }

  Widget referralCode(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'referral',
      builder: builder,
    );
  }

  Widget deviceId(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('deviceid', builder: builder);
  }

  Widget devices(ValueWidgetBuilder<Devices> builder) {
    return subscribedSingleValueBuilder<Devices>(
      'devices',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return Devices.fromBuffer(serialized);
      },
    );
  }

  ///Auth Widgets

  Widget isUserSignedIn(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('IsUserLoggedIn',
        builder: builder, defaultValue: false);
  }

  /// Auth Method channel

  Future<void> signUp(String email, String password) {
    return methodChannel.invokeMethod('signup', <String, dynamic>{
      'email': email,
      'password': password,
    });
  }

  Future<void> signUpEmailResendCode(String email) {
    return methodChannel
        .invokeMethod('signupEmailResendCode', <String, dynamic>{
      'email': email,
    });
  }

  Future<void> signupEmailConfirmation(String email, String code) {
    return methodChannel
        .invokeMethod('signupEmailConfirmation', <String, dynamic>{
      'email': email,
      'code': code,
    });
  }

  Future<void> login(String email, String password) {
    return methodChannel.invokeMethod('login', <String, dynamic>{
      'email': email,
      'password': password,
    });
  }

  Future<void> startRecoveryByEmail(String email) {
    return methodChannel.invokeMethod('startRecoveryByEmail', <String, dynamic>{
      'email': email,
    });
  }

  Future<void> completeRecoveryByEmail(
      String email, String password, String code) {
    return methodChannel
        .invokeMethod('completeRecoveryByEmail', <String, dynamic>{
      'email': email,
      'password': password,
      'code': code,
    });
  }

  Future<void> validateRecoveryCode(String email, String code) {
    return methodChannel.invokeMethod('validateRecoveryCode', <String, dynamic>{
      'email': email,
      'code': code,
    });
  }

  Future<void> changeEmail(String email, String newEmail, String password) {
    return methodChannel.invokeMethod('changeEmail', <String, dynamic>{
      'email': email,
      'newEmail': newEmail,
      'password': password,
    });
  }

  Future<void> signOut() {
    return methodChannel.invokeMethod('signOut', <String, dynamic>{});
  }

  Future<void> deleteAccount(String password) {
    return methodChannel.invokeMethod('deleteAccount', <String, dynamic>{
      'password': password,
    });
  }

  Future<bool> isUserFirstTimeVisit() async {
    final firsTime = await methodChannel
        .invokeMethod<bool>('isUserFirstTimeVisit', <String, dynamic>{});
    print("firsTime $firsTime");
    return !(firsTime ?? false);
  }

  Future<void> setFirstTimeVisit() async {
    return methodChannel
        .invokeMethod<void>('setFirstTimeVisit', <String, dynamic>{});
  }

  /// Auth API end

  Future<void> setProxyAll<T>(bool on) async {
    unawaited(
      methodChannel.invokeMethod('setProxyAll', <String, dynamic>{
        'on': on,
      }),
    );
  }

  Future<String> getCountryCode() async {
    return await methodChannel
        .invokeMethod('getCountryCode', <String, dynamic>{});
  }

  Future<void> setLanguage(String lang) {
    return methodChannel.invokeMethod('setLanguage', <String, dynamic>{
      'lang': lang,
    });
  }

  Future<void> authorizeViaEmail(String emailAddress) {
    return methodChannel.invokeMethod('authorizeViaEmail', <String, dynamic>{
      'emailAddress': emailAddress,
    }).then((value) => value.toString());
  }

  Future<String> validateDeviceRecoveryCode(String code) async {
    return await methodChannel
        .invokeMethod('validateDeviceRecoveryCode', <String, dynamic>{
      'code': code,
    }).then((value) => value.toString());
  }

  Future<String> approveDevice(String code) {
    return methodChannel.invokeMethod('approveDevice', <String, dynamic>{
      'code': code,
    }).then((value) => value.toString() as String);
  }

  Future<void> removeDevice(String deviceId) {
    return methodChannel.invokeMethod('removeDevice', <String, dynamic>{
      'deviceId': deviceId,
    });
  }

  Future<void> setSelectedTab<T>(String tab) async {
    return methodChannel.invokeMethod('setSelectedTab', <String, dynamic>{
      'tab': tab,
    });
  }

  Widget shouldShowGoogleAds(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>(
      'shouldShowGoogleAds',
      builder: builder,
    );
  }

  Widget shouldShowCASAds(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>(
      'shouldShowCASAds',
      builder: builder,
    );
  }

  Widget selectedTab(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      '/selectedTab',
      defaultValue: TAB_VPN,
      builder: builder,
    );
  }

  Widget replicaAddr(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'replicaAddr',
      defaultValue: '',
      builder: builder,
    );
  }

  Widget countryCode(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'geo_country_code',
      defaultValue: '',
      builder: builder,
    );
  }

  Future<String> getReplicaAddr() async {
    final replicaAddr = await methodChannel.invokeMethod('get', 'replicaAddr');
    if (replicaAddr == null || replicaAddr == '') {
      logger.e('Replica not enabled');
    }
    return replicaAddr;
  }

  Widget chatEnabled(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>(
      'chatEnabled',
      defaultValue: false,
      builder: builder,
    );
  }

  Widget sdkVersion(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'sdkVersion',
      defaultValue: 'unknown',
      builder: builder,
    );
  }

  Future<bool> getChatEnabled() async {
    return methodChannel
        .invokeMethod('get', 'chatEnabled')
        .then((enabled) => enabled == true);
  }

  Future<void> checkForUpdates() {
    return methodChannel.invokeMethod('checkForUpdates');
  }

  Widget plans({
    required ValueWidgetBuilder<Iterable<PathAndValue<Plan>>> builder,
  }) {
    return subscribedListBuilder<Plan>(
      '/plans/',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return Plan.fromBuffer(serialized);
      },
    );
  }

  Widget paymentMethods({
    required ValueWidgetBuilder<Iterable<PathAndValue<PaymentMethod>>> builder,
  }) {
    return subscribedListBuilder<PaymentMethod>(
      '/paymentMethods/',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return PaymentMethod.fromBuffer(serialized);
      },
    );
  }

  Future<void> applyRefCode(
    String refCode,
  ) async {
    return methodChannel.invokeMethod('applyRefCode', <String, dynamic>{
      'refCode': refCode,
    }).then((value) => value as String);
  }

  Future<void> reportIssue(
      String email, String issue, String description) async {
    return methodChannel.invokeMethod('reportIssue', <String, dynamic>{
      'email': email,
      'issue': issue,
      'description': description
    }).then((value) => value.toString());
  }

  Widget getUserId(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'userId',
      defaultValue: '',
      builder: builder,
    );
  }

  Widget userStatus(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'userLevel',
      defaultValue: '',
      builder: builder,
    );
  }

  Widget serverInfo(ValueWidgetBuilder<ServerInfo> builder) {
    return subscribedSingleValueBuilder<ServerInfo>(
      '/server_info',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return ServerInfo.fromBuffer(serialized);
      },
    );
  }

  Future<void> requestLinkCode() {
    return methodChannel.invokeMethod('requestLinkCode', {});
  }

  Widget deviceLinkingCode(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'devicelinkingcode',
      defaultValue: '',
      builder: builder,
    );
  }

  Future<void> redeemResellerCode(
    String email,
    String resellerCode,
  ) async {
    return methodChannel.invokeMethod('redeemResellerCode', <String, dynamic>{
      'email': email,
      'resellerCode': resellerCode,
    }).then((value) {
      print("value $value");
    });
  }

  Future<void> submitBitcoinPayment(
    String planID,
    String email,
    String refCode,
  ) async {
    return methodChannel.invokeMethod('submitBitcoinPayment', <String, dynamic>{
      'planID': planID,
      'email': email,
      'refCode': refCode,
    }).then((value) => value as String);
  }

  Future<void> submitGooglePlay(String planID) async {
    return methodChannel
        .invokeMethod('submitGooglePlayPayment', <String, dynamic>{
      'planID': planID,
    }).then((value) => value as String);
  }

  Future<void> submitApplePlay(
      String email, String planID, String purchaseToken) async {
    return methodChannel
        .invokeMethod('submitApplePayPayment', <String, dynamic>{
      'planID': planID,
      'purchaseId': purchaseToken,
      'email': email,
    });
  }

  Future<void> submitStripePayment(
    String planID,
    String email,
    String cardNumber,
    String expDate,
    String cvc,
  ) async {
    return methodChannel.invokeMethod('submitStripePayment', <String, dynamic>{
      'planID': planID,
      'email': email,
      'cardNumber': cardNumber,
      'expDate': expDate,
      'cvc': cvc,
    }).then((value) => value as String);
  }

  Future<void> submitFreekassa(
    String email,
    String planID,
    String currencyPrice,
  ) async {
    return await methodChannel
        .invokeMethod('submitFreekassa', <String, dynamic>{
      'email': email,
      'planID': planID,
      'currencyPrice': currencyPrice,
    });
  }

  Future<void> checkEmailExists(
    String email,
  ) async {
    return methodChannel.invokeMethod('checkEmailExists', <String, dynamic>{
      'emailAddress': email,
    }).then((value) => value as String);
  }

  Future<void> openWebview(String url) {
    return methodChannel.invokeMethod('openWebview', <String, dynamic>{
      'url': url,
    });
  }

  Future<void> refreshAppsList() async {
    await methodChannel.invokeMethod('refreshAppsList');
  }

  Widget splitTunneling(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>(
      '/splitTunneling',
      builder: builder,
    );
  }

  Future<void> setSplitTunneling<T>(bool on) async {
    unawaited(
      methodChannel.invokeMethod('setSplitTunneling', <String, dynamic>{
        'on': on,
      }),
    );
  }

  Widget appsData({
    required ValueWidgetBuilder<Iterable<PathAndValue<AppData>>> builder,
  }) {
    return subscribedListBuilder<AppData>(
      '/appsData/',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return AppData.fromBuffer(serialized);
      },
    );
  }

  Future<void> allowAppAccess(String packageName) {
    return methodChannel.invokeMethod('allowAppAccess', <String, dynamic>{
      'packageName': packageName,
    });
  }

  Future<void> denyAppAccess(String packageName) {
    return methodChannel.invokeMethod('denyAppAccess', <String, dynamic>{
      'packageName': packageName,
    });
  }
}
