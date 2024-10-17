import 'package:intl/intl.dart';
import 'package:lantern/core/utils/utils.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/replica/common.dart';

import '../../core/utils/common.dart';
import '../../core/utils/common_desktop.dart';

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
  late ValueNotifier<bool?> isTestPlayVersion;
  late ValueNotifier<bool?> isStoreVersion;
  late ValueNotifier<bool?> proxyAvailable;
  late ValueNotifier<bool?> proUserNotifier;
  late ValueNotifier<ConfigOptions?> configNotifier;
  late ValueNotifier<String?> country;
  late ValueNotifier<String?> referralNotifier;
  late ValueNotifier<String?> deviceIdNotifier;
  ValueNotifier<String?> langNotifier = ValueNotifier('en_us');
  late ValueNotifier<bool> proxyAllNotifier;
  late ValueNotifier<ServerInfo?> serverInfoNotifier;
  late ValueNotifier<String?> userEmail;
  late ValueNotifier<String?> linkingCodeNotifier;
  late ValueNotifier<Devices?> devicesNotifier;
  late ValueNotifier<bool?> hasUserSignedInNotifier;
  late ValueNotifier<bool?> isAuthEnabled;
  late FfiListNotifier<Plan> plansNotifier;
  late FfiListNotifier<PaymentMethod> paymentMethodsNotifier;
  ValueNotifier<Bandwidth?> bandwidthNotifier = ValueNotifier<Bandwidth?>(null);

  SessionModel() : super('session') {
    if (isMobile()) {
      eventManager = EventManager('lantern_event_channel');
      isStoreVersion = singleValueNotifier(
        'storeVersion',
        false,
      );
      isTestPlayVersion = singleValueNotifier(
        'testPlayVersion',
        false,
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
      hasUserSignedInNotifier = singleValueNotifier('IsUserLoggedIn', false);
      proUserNotifier = singleValueNotifier('prouser', false);
      userEmail = singleValueNotifier(
        'emailAddress',
        "",
      );
      isAuthEnabled = singleValueNotifier(
        'authEnabled',
        false,
      );
    } else {
      bandwidthNotifier = ValueNotifier<Bandwidth?>(null);
      configNotifier = ValueNotifier<ConfigOptions?>(null);
      country = ValueNotifier('US');
      linkingCodeNotifier = ValueNotifier('');
      proxyAvailable = ValueNotifier(false);
      userEmail = ValueNotifier("");
      proUserNotifier = ValueNotifier(false);
      plansNotifier = FfiListNotifier<Plan>('/plans/', () => {});
      paymentMethodsNotifier =
          FfiListNotifier<PaymentMethod>('/paymentMethods/', () => {});
      hasUserSignedInNotifier = ValueNotifier(false);
      serverInfoNotifier = ValueNotifier<ServerInfo?>(null);
      proxyAllNotifier = ValueNotifier(false);
      referralNotifier = ValueNotifier('');
      deviceIdNotifier = ValueNotifier('');
      isAuthEnabled = ValueNotifier(false);
      isStoreVersion = ValueNotifier(false);
      isTestPlayVersion = ValueNotifier(false);
    }
    if (Platform.isAndroid) {
      // By default when user starts the app we need to make sure that screenshot is disabled
      // if user goes to chat then screenshot will be disabled
      enableScreenShot();
    }
  }

  ValueNotifier<T?> pathValueNotifier<T>(String path, T defaultValue) {
    return singleValueNotifier(path, defaultValue);
  }

  Future<void> updateUserDetails() {
    return methodChannel.invokeMethod('updateUserDetail', {});
  }

  Widget configValueBuilder<T>(
    String path,
    ValueWidgetBuilder<T> builder,
    T Function(ConfigOptions? options) onConfigUpdate,
  ) {
    return SubscribedSingleValueBuilder<ConfigOptions?>(
      path,
      configNotifier,
      (BuildContext context, ConfigOptions? value, Widget? child) =>
          value == null
              ? const SizedBox()
              : builder(context, onConfigUpdate(value), child),
    );
  }

  Widget proUser(ValueWidgetBuilder<bool> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>('prouser', builder: builder,defaultValue: false);
    }
    return FfiValueBuilder<bool>('prouser', proUserNotifier, builder);
  }

  Widget bandwidth(ValueWidgetBuilder<Bandwidth> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<Bandwidth>(
        '/bandwidth',
        builder: builder,
        deserialize: (Uint8List serialized) {
          return Bandwidth.fromBuffer(serialized);
        },
      );
    }
    return FfiValueBuilder<Bandwidth>('bandwidth', bandwidthNotifier, builder);
  }

  Widget developmentMode(ValueWidgetBuilder<bool> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>(
        'developmentMode',
        builder: builder,
      );
    }
    return configValueBuilder(
        'developmentMode', builder, (value) => value?.developmentMode ?? false);
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
    return configValueBuilder('accepted_terms_version', builder,
        (value) => value?.chat.acceptedTermsVersion ?? 0);
  }

  Widget forceCountry(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'forceCountry',
      builder: builder,
    );
  }

  Future<void> setForceCountry(String? countryCode) {
    return methodChannel.invokeMethod('setForceCountry', countryCode);
  }

  Widget geoCountryCode(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      'geo_country_code',
      builder: builder,
    );
  }

  Widget storeVersion(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('storeVersion', builder: builder);
  }

  Widget testPlayVersion(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('testPlayVersion',
        builder: builder, defaultValue: false);
  }

  Future<void> setTestPlayVersion(bool on) {
    return methodChannel.invokeMethod('setTestPlayVesion', <String, dynamic>{
      'on': on,
    });
  }

  Widget language(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>('lang', builder: builder);
    }
    return FfiValueBuilder<String>('lang', langNotifier, builder);
  }

  Widget emailAddress(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'emailAddress',
        builder: builder,
      );
    }
    return FfiValueBuilder<String>('emailAddress', userEmail, builder);
  }

  Widget expiryDate(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'expirydatestr',
        builder: builder,
      );
    }
    return configValueBuilder(
        'expirydatestr', builder, (value) => value?.expirationDate ?? '');
  }

  Widget referralCode(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'referral',
        builder: builder,
      );
    }
    return FfiValueBuilder<String>('referralCode', referralNotifier, builder);
  }

  Widget deviceId(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>('deviceid', builder: builder);
    }
    return FfiValueBuilder<String>('deviceid', deviceIdNotifier, builder);
  }

  Widget devices(ValueWidgetBuilder<Devices> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<Devices>(
        'devices',
        builder: builder,
        deserialize: (Uint8List serialized) {
          return Devices.fromBuffer(serialized);
        },
      );
    }
    // update the logic of devices
    return configValueBuilder(
        'devices', builder, (options) => options!.devices);
  }

  /// This only supports desktop fo now
  Future<void> testProviderRequest(
      String email, String paymentProvider, String planId) {
    if (isMobile()) {
      return methodChannel
          .invokeMethod('testProviderRequest', <String, dynamic>{
        'email': email,
        'provider': paymentProvider,
        'planId': planId,
      });
    }
    return compute(
        LanternFFI.testPaymentRequest, [email, paymentProvider, planId]);
  }

  ///Auth Widgets

  Pointer<Utf8> ffiIsUserLoggedIn() => LanternFFI.isUserLoggedIn();

  Widget isUserSignedIn(ValueWidgetBuilder<bool> builder) {
    if (isDesktop()) {
      return FfiValueBuilder<bool>(
          'isUserLoggedIn', hasUserSignedInNotifier, builder);
    }
    return subscribedSingleValueBuilder<bool>('IsUserLoggedIn',
        builder: builder, defaultValue: false);
  }

  /// Auth Method channel

  Future<void> signUp(String email, String password) {
    if (isDesktop()) {
      return compute(LanternFFI.signUp, [email, password]);
    }
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
    if (isDesktop()) {
      return compute(LanternFFI.login, [email, password]);
    }
    return methodChannel.invokeMethod('login', <String, dynamic>{
      'email': email,
      'password': password,
    });
  }

  Future<void> startRecoveryByEmail(String email) {
    if (isDesktop()) {
      return compute(LanternFFI.startRecoveryByEmail, email);
    }
    return methodChannel.invokeMethod('startRecoveryByEmail', <String, dynamic>{
      'email': email,
    });
  }

  Future<void> completeRecoveryByEmail(
      String email, String password, String code) {
    if (isDesktop()) {
      return compute(
          LanternFFI.completeRecoveryByEmail, [email, password, code]);
    }
    return methodChannel
        .invokeMethod('completeRecoveryByEmail', <String, dynamic>{
      'email': email,
      'password': password,
      'code': code,
    });
  }

  Future<void> validateRecoveryCode(String email, String code) {
    if (isDesktop()) {
      return compute(LanternFFI.validateRecoveryByEmail, [email, code]);
    }
    return methodChannel.invokeMethod('validateRecoveryCode', <String, dynamic>{
      'email': email,
      'code': code,
    });
  }

  Future<void> startChangeEmail(
      String email, String newEmail, String password) {
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
    if (isDesktop()) {
      return compute(LanternFFI.logout, '');
    }
    return methodChannel.invokeMethod('signOut', <String, dynamic>{});
  }

  Future<void> deleteAccount(String password) {
    if (isDesktop()) {
      return compute(LanternFFI.deleteAccount, password);
    }
    return methodChannel.invokeMethod('deleteAccount', <String, dynamic>{
      'password': password,
    });
  }

  Future<bool> isUserFirstTimeVisit() async {
    if (isDesktop()) {
      return await LanternFFI.userFirstVisit();
    }
    final firsTime = await methodChannel
        .invokeMethod<bool>('isUserFirstTimeVisit', <String, dynamic>{});
    return firsTime ?? false;
  }

  Future<void> setFirstTimeVisit() async {
    if (isDesktop()) {
      return LanternFFI.setUserFirstTimeVisit();
    }
    return methodChannel
        .invokeMethod<void>('setFirstTimeVisit', <String, dynamic>{});
  }

  Future<void> setProxyAll<T>(bool isOn) async {
    if (isDesktop()) {
      return await compute(LanternFFI.setProxyAll, isOn ? 'true' : 'false');
    }
    throw Exception("Not supported on mobile");
  }

  Future<String> proxyAddr() async {
    return await methodChannel.invokeMethod('proxyAddr', <String, dynamic>{});
  }

  /// Auth API end
  Future<String> getCountryCode() async {
    return await methodChannel
        .invokeMethod('getCountryCode', <String, dynamic>{});
  }

  Future<void> setLanguage(String lang) async {
    if (isMobile()) {
      return methodChannel.invokeMethod('setLanguage', <String, dynamic>{
        'lang': lang,
      });
    }
    Localization.locale = lang;
    return await compute(LanternFFI.setLang, lang);
  }

  Future<void> userEmailRequest(String email) async {
    if (isMobile()) {
      return await methodChannel
          .invokeMethod('userEmailRequest', <String, dynamic>{
        'email': email,
      });
    }
    throw Exception("Not supported on desktop");
  }

  Future<void> authorizeViaEmail(String emailAddress) async {
    if (isMobile()) {
      return methodChannel.invokeMethod('authorizeViaEmail', <String, dynamic>{
        'emailAddress': emailAddress,
      }).then((value) => value.toString());
    }
    return await compute(LanternFFI.authorizeEmail, emailAddress);
  }

  Future<void> validateDeviceRecoveryCode(String code, String email) async {
    if (isMobile()) {
      return await methodChannel
          .invokeMethod('validateRecoveryCode', <String, dynamic>{
        'code': code,
        'email': email,
      }).then((value) => value.toString());
    }
    return await compute(LanternFFI.userLinkValidate, code);
  }

  Future<void> approveDevice(String code) async {
    if (isMobile()) {
      return methodChannel.invokeMethod('approveDevice', <String, dynamic>{
        'code': code,
      });
    }
    return await compute(LanternFFI.approveDevice, code);
  }

  Future<void> removeDevice(String deviceId) async {
    if (isMobile()) {
      return methodChannel.invokeMethod('removeDevice', <String, dynamic>{
        'deviceId': deviceId,
      });
    }
    return await compute(LanternFFI.removeDevice, deviceId);
  }

  Future<void> resendRecoveryCode() {
    return methodChannel
        .invokeMethod('resendRecoveryCode', <String, dynamic>{});
  }

  void setSelectedTab(BuildContext context, String tab) {
    Provider.of<BottomBarChangeNotifier>(context, listen: false)
        .setCurrentIndex(tab);
  }

  /// this is only used for android and ios
  /// if string value is "" then it will not show ads
  /// if string value is "tapsell" then it will show tapsell ads
  /// if string value is "admob" then it will show admob ads
  Widget shouldShowAds(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('showAds',
        builder: builder, defaultValue: '');
  }

  Widget replicaAddr(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'replicaAddr',
        defaultValue: '',
        builder: builder,
      );
    }
    return configValueBuilder(
        'replicaAddr', builder, (value) => value?.replicaAddr ?? '');
  }

  Widget countryCode(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'geo_country_code',
        defaultValue: '',
        builder: builder,
      );
    }
    return FfiValueBuilder<String>('lang', country, builder);
  }

  Future<String> getReplicaAddr() async {
    try {
      final replicaAddr =
          await methodChannel.invokeMethod('get', 'replicaAddr');
      if (replicaAddr == null || replicaAddr == '') {
        logger.e('Replica not enabled');
      }
      return replicaAddr;
    } catch (e) {
      logger.e('Error getting replica address: $e');
      return '';
    }
  }

  Widget chatEnabled(ValueWidgetBuilder<bool> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>(
        'chatEnabled',
        defaultValue: false,
        builder: builder,
      );
    }
    return configValueBuilder(
        'chatEnabled', builder, (value) => value?.chatEnabled ?? false);
  }

  Widget sdkVersion(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'sdkVersion',
        defaultValue: 'unknown',
        builder: builder,
      );
    }
    return configValueBuilder(
        'sdkVersion', builder, (value) => value?.sdkVersion ?? "");
  }

  Future<bool> getChatEnabled() async {
    return methodChannel
        .invokeMethod('chatEnabled', '')
        .then((enabled) => enabled == true);
  }

  Future<String?> checkForUpdates() async {
    if (isMobile()) {
      if (Platform.isAndroid) {
        return methodChannel.invokeMethod('checkForUpdates');
      } else {
        AppMethods.openAppstore();
        return "";
      }
    } else {
      final updateUrl = await compute(LanternFFI.checkUpdates, '');
      return updateUrl;
    }
  }

  // Plans and payment methods
  Future<void> restoreAccount(String email, String code) async {
    return methodChannel.invokeMethod('restoreAccount', <String, dynamic>{
      "email": email,
      "code": code,
      "provider": Platform.isAndroid ? "googleplay" : "applepay"
    });
  }

  Future<void> updatePaymentPlans() async {
    return methodChannel.invokeMethod('updatePaymentPlans', '');
  }

  Future<bool> hasUpdatePlansOrBuy() async {
    return compute(LanternFFI.hasPlanUpdateOrBuy, '');
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
    return FfiListBuilder<Plan>(
      '/plans/',
      plansNotifier,
      (BuildContext context, ChangeTrackingList<Plan> value, Widget? child) =>
          builder(
        context,
        value.map.entries.map((e) => PathAndValue(e.key, e.value)),
        child,
      ),
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
    return FfiListBuilder<PaymentMethod>(
      '/paymentMethods/',
      paymentMethodsNotifier,
      (BuildContext context, ChangeTrackingList<PaymentMethod> value,
              Widget? child) =>
          builder(
        context,
        value.map.entries.map((e) => PathAndValue(e.key, e.value)),
        child,
      ),
    );
  }

  Future<void> applyRefCode(
    String refCode,
  ) async {
    if (isDesktop()) {
      return await compute(LanternFFI.ffiApplyRefCode, refCode);
    }
    return methodChannel.invokeMethod('applyRefCode', <String, dynamic>{
      'refCode': refCode,
    }).then((value) => value as String);
  }

  Future<void> reportIssue(
      String email, String issue, String description) async {
    if (isDesktop()) {
      return await compute(LanternFFI.reportIssue, [email, issue, description]);
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

  Widget serverInfo(ValueWidgetBuilder<ServerInfo?> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<ServerInfo?>(
        '/server_info',
        builder: builder,
        deserialize: (Uint8List serialized) {
          return ServerInfo.fromBuffer(serialized);
        },
      );
    }
    return FfiValueBuilder<ServerInfo?>(
        'serverInfo', serverInfoNotifier, builder);
  }

  Future<void> trackUserAction(
    String name,
    String url, [
    String title = '',
  ]) async {
    if (Platform.isAndroid) {
      return methodChannel.invokeMethod('trackUserAction', <String, dynamic>{
        'name': name,
        'url': url,
        'title': title,
      });
    }
  }

  Future<String> requestLinkCode() {
    return methodChannel
        .invokeMethod('requestLinkCode', '')
        .then((value) => value.toString());
  }

  Future<void> redeemLinkCode() {
    return methodChannel.invokeMethod('redeemLinkCode', {});
  }

  Widget deviceLinkingCode(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        'devicelinkingcode',
        defaultValue: '',
        builder: builder,
      );
    }
    return FfiValueBuilder<String>(
        'deviceLinkingCode', linkingCodeNotifier, builder);
  }

  Future<void> redeemResellerCode(
    String email,
    String currency,
    String deviceName,
    String resellerCode,
  ) async {
    if (isMobile()) {
      return methodChannel.invokeMethod('redeemResellerCode', <String, dynamic>{
        'email': email,
        'resellerCode': resellerCode,
      });
    }

    await compute(LanternFFI.redeemResellerCode,
        [email, currency, deviceName, resellerCode]);
  }

  Future<String> submitBitcoinPayment(
    String planID,
    String email,
  ) async {
    return methodChannel.invokeMethod('submitBitcoinPayment', <String, dynamic>{
      'planID': planID,
      'email': email
    }).then((value) => value as String);
  }

  Future<String> generatePaymentRedirectUrl({
    required String planID,
    required String email,
    required Providers paymentProvider,
  }) {
    return methodChannel.invokeMethod(
        'generatePaymentRedirectUrl', <String, dynamic>{
      'planID': planID,
      'email': email,
      'provider': paymentProvider.name
    }).then((value) => value as String);
  }

  Future<bool> isGooglePlayServiceAvailable() async {
    final result = await methodChannel.invokeMethod('isPlayServiceAvailable');
    return result as bool;
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

  Future<String> paymentRedirectForDesktop(BuildContext context, String planID,
      String email, Providers provider) async {
    String os = Platform.operatingSystem;
    Locale locale = Localizations.localeOf(context);
    final format = NumberFormat.simpleCurrency(locale: locale.toString());
    final currencyName = format.currencyName ?? "USD";
    return await compute(LanternFFI.paymentRedirect,
        [planID, currencyName, provider.name, email, os]);
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
    if (isMobile()) {
      return methodChannel.invokeMethod('checkEmailExists', <String, dynamic>{
        'emailAddress': email,
      }).then((value) => value as String);
    }
    await compute(LanternFFI.emailExists, email);
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
    return configValueBuilder(
        'splitTunneling', builder, (value) => value?.splitTunneling ?? false);
  }

  Widget proxyAll(ValueWidgetBuilder<bool> builder) {
    return FfiValueBuilder<bool>('proxyAll', proxyAllNotifier, builder);
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

  Future<void> enableScreenShot() {
    return methodChannel.invokeMethod('enableScreenshot', <String, dynamic>{});
  }

  Future<void> disableScreenShot() {
    return methodChannel.invokeMethod('disableScreenshot', <String, dynamic>{});
  }
}
