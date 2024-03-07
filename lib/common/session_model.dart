import 'package:fixnum/fixnum.dart';
import 'package:intl/intl.dart';
import 'package:lantern/replica/common.dart';

import 'common.dart';
import 'common_desktop.dart';

final sessionModel = SessionModel();

const TAB_CHATS = 'chats';
const TAB_VPN = 'vpn';
const TAB_HOME = 'home';
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
    if (isMobile()) {
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
      /*Note
      * Make proxyAvailable default value to true on IOS it take some to get data from go side
      * So show banner only if proxyAvailable is false
      */
      proxyAvailable = singleValueNotifier('hasSucceedingProxy', true);
      country = singleValueNotifier('geo_country_code', 'US');
    } else {
      country = ffiValueNotifier(ffiLang, 'lang', 'US');
      isPlayVersion = ffiValueNotifier(
        ffiPlayVersion,
        'isPlayVersion',
        false,
      );
      isStoreVersion = ffiValueNotifier(
        ffiStoreVersion,
        'isStoreVersion',
        false,
      );
      proxyAvailable = ffiValueNotifier(
        ffiHasSucceedingProxy,
        'hasSucceedingProxy',
        false,
      );
    }
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
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>('prouser', builder: builder);
    }
    return ffiValueBuilder<bool>(
      'prouser',
      defaultValue: false,
      ffiProUser,
      builder: builder,
    );
  }

  Widget developmentMode(ValueWidgetBuilder<bool> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>(
        'developmentMode',
        builder: builder,
      );
    }
    return ffiValueBuilder<bool>(
      'developmentMode',
      defaultValue: false,
      ffiDevelopmentMode,
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
    if (isMobile()) {
      return subscribedSingleValueBuilder<int>('accepted_terms_version',
          builder: builder, defaultValue: 0);
    }
    return ffiValueBuilder<int>(
      'accepted_terms_version',
      defaultValue: 0,
      ffiAcceptedTermsVersion,
      builder: builder,
    );
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
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>('lang', builder: builder);
    }
    return ffiValueBuilder<String>(
      'lang',
      defaultValue: 'en',
      ffiLang,
      builder: builder,
    );
  }

  Widget emailAddress(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'emailAddress',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'emailAddress',
      ffiEmailAddress,
      defaultValue: '',
      builder: builder,
    );
  }

  Widget expiryDate(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'expirydatestr',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'emailAddress',
      ffiEmailAddress,
      defaultValue: '',
      builder: builder,
    );
  }

  Widget referralCode(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'referral',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'referral',
      ffiReferral,
      defaultValue: '',
      builder: builder,
    );
  }

  Widget deviceId(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>('deviceid', builder: builder);
    }
    return ffiValueBuilder<String>(
      'referral',
      ffiReferral,
      defaultValue: '',
      builder: builder,
    );
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

  Future<void> startChangeEmail(String email, String newEmail, String password) {
    return methodChannel.invokeMethod('startChangeEmail', <String, dynamic>{
      'email': email,
      'newEmail': newEmail,
      'password': password,
    });
  }

  Future<void> completeChangeEmail(
      String email, String newEmail, String password, String code) {
    return methodChannel.invokeMethod('completeChangeEmail', <String, dynamic>{
      'email': email,
      'newEmail': newEmail,
      'password': password,
      'code': code,
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
    if (isMobile()) {
      return methodChannel.invokeMethod('setLanguage', <String, dynamic>{
        'lang': lang,
      });
    }
    // Desktop users
    final newLang = lang.toNativeUtf8();
    setLang(newLang);
    return Future(() => null);
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
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        '/selectedTab',
        defaultValue: TAB_VPN,
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'selectedTab',
      ffiSelectedTab,
      defaultValue: TAB_VPN,
      builder: builder,
    );
  }

  Widget replicaAddr(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'replicaAddr',
        defaultValue: '',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'replicaAddr',
      ffiReplicaAddr,
      defaultValue: '',
      builder: builder,
    );
  }

  Widget countryCode(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'geo_country_code',
        defaultValue: '',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'lang',
      defaultValue: 'US',
      ffiLang,
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
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>(
        'chatEnabled',
        defaultValue: false,
        builder: builder,
      );
    }
    return ffiValueBuilder<bool>(
      'chatEnabled',
      ffiChatEnabled,
      defaultValue: false,
      builder: builder,
    );
  }

  Widget sdkVersion(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'sdkVersion',
        defaultValue: 'unknown',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'sdkVersion',
      defaultValue: 'unknown',
      ffiSdkVersion,
      builder: builder,
    );
  }

  Future<bool> getChatEnabled() async {
    return methodChannel
        .invokeMethod('get', 'chatEnabled')
        .then((enabled) => enabled == true);
  }

  Future<void> checkForUpdates() async {
    if (Platform.isAndroid) {
      return methodChannel.invokeMethod('checkForUpdates');
    } else if (isDesktop()) {
      await ffiCheckUpdates();
    }
    return;
  }

  Plan planFromJson(Map<String, dynamic> item) {
    final formatCurrency = new NumberFormat.simpleCurrency();
    var id = item['id'];
    var plan = Plan();
    plan.id = id;
    plan.description = item["description"];
    plan.oneMonthCost = formatCurrency
        .format(item["expectedMonthlyPrice"]["usd"] / 100)
        .toString();
    plan.totalCost = formatCurrency.format(item["usdPrice"] / 100).toString();
    plan.totalCostBilledOneTime =
        formatCurrency.format(item["usdPrice"] / 100).toString() +
            ' ' +
            'billed_one_time'.i18n;
    plan.bestValue = item["bestValue"] ?? false;
    plan.usdPrice = Int64(item["usdPrice"]);
    return plan;
  }

  PaymentMethod paymentMethodFromJson(Map<String, dynamic> item) {
    final formatCurrency = new NumberFormat.simpleCurrency();
    final List<PaymentMethod> methods = [];
    for (var m in item["desktop"]) {
      var paymentMethod = PaymentMethod();
      paymentMethod.method = m["method"];
      var providers = <PaymentProviders>[];
      for (var n in m["providers"]) {
        var provider = PaymentProviders();
        provider.name = n["name"];
        providers.add(provider);
      }
      paymentMethod.providers.addAll(providers);
      return paymentMethod;
    }
    return PaymentMethod();
  }

  Widget plans({
    required ValueWidgetBuilder<Iterable<PathAndValue<Plan>>> builder,
  }) {
    if (isMobile()) {
      return subscribedListBuilder<Plan>(
        '/plans/',
        builder: builder,
        deserialize: (Uint8List serialized) {
          return Plan.fromBuffer(serialized);
        },
      );
    }
    return ffiListBuilder<Plan>(
      '/plans/',
      ffiPlans,
      planFromJson,
      builder: builder,
      deserialize: (Uint8List serialized) {
        return Plan.fromBuffer(serialized);
      },
    );
  }

  Widget paymentMethods({
    required ValueWidgetBuilder<Iterable<PathAndValue<PaymentMethod>>> builder,
  }) {
    if (isMobile()) {
      return subscribedListBuilder<PaymentMethod>(
        '/paymentMethods/',
        builder: builder,
        deserialize: (Uint8List serialized) {
          return PaymentMethod.fromBuffer(serialized);
        },
      );
    }
    return ffiListBuilder<PaymentMethod>(
      '/paymentMethods/',
      ffiPaymentMethods,
      paymentMethodFromJson,
      builder: builder,
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
    if (isDesktop()) {
      await ffiReportIssue(email.toNativeUtf8(), issue.toNativeUtf8(),
          description.toNativeUtf8());
      return;
    }
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
    if (isMobile()) {
      return subscribedSingleValueBuilder<ServerInfo>(
        '/server_info',
        builder: builder,
        deserialize: (Uint8List serialized) {
          return ServerInfo.fromBuffer(serialized);
        },
      );
    }
    return ffiValueBuilder<ServerInfo>(
      'serverInfo',
      ffiServerInfo,
      builder: builder,
      fromJsonModel: (Map<String, dynamic> json) {
        var info = ServerInfo();
        info.city = json['city'];
        info.country = json['country'];
        info.countryCode = json['countryCode'];
        return info;
      },
      deserialize: (Uint8List serialized) {
        return ServerInfo.fromBuffer(serialized);
      },
    );
  }

  Future<void> trackUserAction(
    String name,
    String url,
    String title,
  ) async {
    return methodChannel.invokeMethod('trackUserAction', <String, dynamic>{
      'name': name,
      'url': url,
      'title': title,
    });
  }

  Future<String> requestLinkCode() {
    return methodChannel
        .invokeMethod('requestLinkCode')
        .then((value) => value.toString());
  }


  Future<void> requestLinkCode() {
    return methodChannel.invokeMethod('requestLinkCode', {});
  }

  Widget deviceLinkingCode(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'devicelinkingcode',
        defaultValue: '',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'deviceLinkingCode',
      defaultValue: '',
      ffiDeviceLinkingCode,
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
      print('value $value');
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

  Future<void> submitPlayPayment(
    String planID,
    String email,
  ) async {
    return methodChannel
        .invokeMethod('submitGooglePlayPayment', <String, dynamic>{
      'email': email,
      'planID': planID,
    }).then((value) => value as String);
  }

   Future<String> paymentRedirect(
    String planID,
    String email,
    String provider,
    String deviceName,
  ) async {
    final resp = await ffiPaymentRedirect(
        planID.toNativeUtf8(),
        provider.toNativeUtf8(),
        email.toNativeUtf8(),
        deviceName.toNativeUtf8());
    return resp.toDartString();
  }
  
  Future<void> submitApplePlay(String email,String planID, String purchaseToken) async {
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
    if (isMobile()) {
      return methodChannel
          .invokeMethod('submitStripePayment', <String, dynamic>{
        'planID': planID,
        'email': email,
        'cardNumber': cardNumber,
        'expDate': expDate,
        'cvc': cvc,
      }).then((value) => value as String);
    }
    await ffiPurchase(planID.toNativeUtf8(), email.toNativeUtf8(),
        cardNumber.toNativeUtf8(), expDate.toNativeUtf8(), cvc.toNativeUtf8());
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
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>(
        '/splitTunneling',
        builder: builder,
      );
    }
    return ffiValueBuilder<bool>(
      'splitTunneling',
      ffiSplitTunneling,
      defaultValue: false,
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
