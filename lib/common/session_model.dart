import 'package:fixnum/fixnum.dart';
import 'package:intl/intl.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/plans/utils.dart';
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
  ValueNotifier<bool?>? isPlayVersion;
  ValueNotifier<bool?>? isStoreVersion;
  late ValueNotifier<bool?> proxyAvailable;
  late ValueNotifier<bool?> proUserNotifier;
  late ValueNotifier<String?> country;
  late ValueNotifier<String?> userEmail;
  late ValueNotifier<bool?> hasUserSignedInNotifier;
  late ValueNotifier<bool?> isAuthEnabled;

  SessionModel() : super('session') {
    if (isMobile()) {
      eventManager = EventManager('lantern_event_channel');

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
      country = ffiValueNotifier(ffiLang, 'lang', 'US');
      proxyAvailable = ffiValueNotifier(
        ffiSucceedingProxy,
        'hasSucceedingProxy',
        false,
      );
      userEmail = ffiValueNotifier(ffiEmailAddress, 'emailAddress', "");
      proUserNotifier = ffiValueNotifier(ffiProUser, 'prouser', false);
      hasUserSignedInNotifier = ffiValueNotifier(ffiIsUserLoggedIn, 'IsUserLoggedIn', false);
      isAuthEnabled = ffiValueNotifier(ffiAuthEnabled, 'authEnabled', false);
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

  Pointer<Utf8> ffiAuthEnabled() => LanternFFI.authEnabled();

  Pointer<Utf8> ffiProUser() => LanternFFI.proUser();

  Pointer<Utf8> ffiSucceedingProxy() => LanternFFI.hasSucceedingProxy();

  Widget proUser(ValueWidgetBuilder<bool> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>('prouser', builder: builder);
    }
    final websocket = WebsocketImpl.instance();
    return ffiValueBuilder<bool>(
      'prouser',
      null,
      defaultValue: false,
      onChanges: (setValue) => {
        listenWebsocket(websocket, 'pro', null, (p0) {
          if (p0 != null) {
            final res = p0 as Map<String, dynamic>;
            final isPro = res['userStatus'] == 'active' || res['userLevel'] == 'pro';
            if (isPro) setValue(isPro);
          }
        })
      },
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
      null,
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
      null,
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

  Pointer<Utf8> ffiLang() => LanternFFI.lang();

  Widget language(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>('lang', builder: builder);
    }
    final websocket = WebsocketImpl.instance();
    return ffiValueBuilder<String>(
      'lang',
      defaultValue: 'en',
      onChanges: (setValue) =>
          listenWebsocket(websocket, "pro", "language", (value) {
        if (value != null && value.toString() != "") setValue(value.toString());
      }),
      null,
      builder: builder,
    );
  }

  Pointer<Utf8> ffiEmailAddress() => LanternFFI.emailAddress();

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
      'expirydatestr',
      null,
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
      LanternFFI.referral,
      defaultValue: '',
      builder: builder,
    );
  }

  Widget deviceId(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>('deviceid', builder: builder);
    }
    return ffiValueBuilder<String>(
      'deviceid',
      LanternFFI.deviceId,
      defaultValue: '',
      builder: builder,
    );
  }

  Devices devicesFromJson(dynamic item) {
    final devices = <Device>[];
    for (final element in item) {
      if (element is! Map) continue;
      try {
        devices.add(Device.create()..mergeFromProto3Json(element));
      } on Exception catch (e) {
        // Handle parsing errors as needed
        appLogger.i("Error parsing device data: $e");
      }
    }
    return Devices.create()..devices.addAll(devices);
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
    return ffiValueBuilder<Devices>(
      'devices',
      LanternFFI.devices,
      fromJsonModel: devicesFromJson,
      defaultValue: null,
      builder: builder,
    );
  }

  /// This only supports desktop fo now
  Future<void> testProviderRequest(
      String email, String paymentProvider, String planId) {
    return compute(
        LanternFFI.testPaymentRequest, [email, paymentProvider, planId]);
  }

  ///Auth Widgets

  Pointer<Utf8> ffiIsUserLoggedIn() => LanternFFI.isUserLoggedIn();

  Widget isUserSignedIn(ValueWidgetBuilder<bool> builder) {
    final websocket = WebsocketImpl.instance();
    if (isDesktop()) {
      return ffiValueBuilder<bool>(
        'IsUserLoggedIn',
        ffiIsUserLoggedIn,
        defaultValue: false,
        builder: builder,
        onChanges: (setValue) {
          listenWebsocket(websocket, 'pro', 'login', (userLoggedIn) {
            if (userLoggedIn != null) {
              setValue(userLoggedIn as bool);
            }
          });
        },
      );
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

  /// Auth API end
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
    Localization.locale = lang;
    return Future(() => null);
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
      });
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

  Widget shouldShowGoogleAds(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>(
      'shouldShowGoogleAds',
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
      null,
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

  // Widget authEnabled(ValueWidgetBuilder<bool> builder) {
  //   if (isMobile()) {
  //     return subscribedSingleValueBuilder<bool>(
  //       'authEnabled',
  //       defaultValue: false,
  //       builder: builder,
  //     );
  //   }
  //   return ffiValueBuilder<bool>(
  //     'authEnabled',
  //     ffiAuthEnabled,
  //     defaultValue: false,
  //     builder: builder,
  //   );
  // }

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
      LanternFFI.chatEnabled,
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
      LanternFFI.sdkVersion,
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
      await LanternFFI.checkUpdates();
    }
    return;
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
    return methodChannel.invokeMethod('updatePaymentPlans');
  }

  Future<bool> hasUpdatePlansOrBuy() async {
    return compute(LanternFFI.hasPlanUpdateOrBuy, '');
  }

  Plan planFromJson(Map<String, dynamic> item) {
    print("called plans $item");
    final locale = Localization.locale;
    final formatCurrency = NumberFormat.simpleCurrency(locale: locale);
    String currency = formatCurrency.currencyName != null
        ? formatCurrency.currencyName!.toLowerCase()
        : "usd";
    final res = jsonEncode(item);
    final plan = Plan.create()..mergeFromProto3Json(jsonDecode(res));
    if (plan.price[currency] == null) {
      final splitted = plan.id.split('-');
      if (splitted.length == 3) {
        currency = splitted[1];
      }
    }

    if (plan.price[currency] == null) {
      return plan;
    }
    if (plan.price[currency] != null) {
      final price = plan.price[currency] as Int64;
      plan.totalCost = formatCurrency.format(price.toInt() / 100.0).toString();
      plan.totalCostBilledOneTime =
          '${formatCurrency.format(price.toInt() / 100)} ${'billed_one_time'.i18n}';
    }
    return plan;
  }

  Iterable<PathAndValue<PaymentMethod>> paymentMethodFromJson(item) {
    final Map<String, dynamic> icons = item['icons'];
    final desktopProviders = item['providers']["desktop"] as List;
    return desktopProviders.map((method) {
      final paymentMethod = PaymentMethod()..method = method["method"];
      final providers = method["providers"].map<PaymentProviders>((provider) {
        final List<dynamic> logos = icons[provider["name"]];
        final List<String> stringLogos =
            logos.map((logo) => logo.toString()).toList();
        return PaymentProviders.create()
          ..logoUrls.addAll(stringLogos)
          ..name = provider["name"];
      }).toList();

      paymentMethod.providers.addAll(providers);
      return PathAndValue<PaymentMethod>(paymentMethod.method, paymentMethod);
    });
  }

  Pointer<Utf8> ffiPlans() => LanternFFI.plans();

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

  Future<Iterable<PathAndValue<PaymentMethod>>> paymentMethodsv4() async {
    final res = LanternFFI.paymentMethodsV4();
    return paymentMethodFromJson(jsonDecode(res.toDartString()));
  }

  Pointer<Utf8> ffiPaymentMethodsV4() => LanternFFI.paymentMethodsV4();

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

    return ffiValueBuilder<Iterable<PathAndValue<PaymentMethod>>>(
      "/paymentMethods/",
      ffiPaymentMethodsV4,
      fromJsonModel: paymentMethodFromJson,
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

  ServerInfo serverInfoFromJson(dynamic? res) {
    if (res != null) {
      final res2 = jsonDecode(jsonEncode(res));
      if (res2 != null) {
        return ServerInfo.create()
          ..mergeFromProto3Json({
            'countryCode': res2['countryCode'],
            'country': res2['country'],
            'city': res2['city'],
          });
      }
    }
    return ServerInfo.create();
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
    final websocket = WebsocketImpl.instance();
    return ffiValueBuilder<ServerInfo?>(
      'serverInfo',
      null,
      onChanges: (setValue) {
        listenWebsocket(websocket, 'stats', null, (res) {
          if (res != null) setValue(res as ServerInfo);
        });
      },
      defaultValue: null,
      fromJsonModel: serverInfoFromJson,
      builder: builder,
    );
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
        .invokeMethod('requestLinkCode')
        .then((value) => value.toString());
  }

  Future<void> redeemLinkCode() {
    return methodChannel.invokeMethod('redeemLinkCode');
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
      LanternFFI.deviceLinkingCode,
      builder: builder,
    );
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
      LanternFFI.splitTunneling,
      defaultValue: false,
      builder: builder,
    );
  }

  Pointer<Utf8> ffiProxyAll() => LanternFFI.proxyAll();

  Widget proxyAll(ValueWidgetBuilder<bool> builder) {
    final websocket = WebsocketImpl.instance();
    return ffiValueBuilder<bool>(
      'proxyAll',
      defaultValue: false,
      onChanges: (setValue) =>
          listenWebsocket(websocket, "settings", "proxyAll", (value) {
        if (value != null) setValue(value as bool);
      }),
      ffiProxyAll,
      builder: builder,
    );
  }

  // listenWebsocket listens for websocket messages from the server. If a message matches the given message type,
  // the onMessage callback is triggered with the given property value
  void listenWebsocket<T>(WebsocketImpl? websocket, String messageType,
      String? property, void Function(T?) onMessage) {
    if (websocket == null) return;
    websocket.messageStream.listen(
      (json) {
        print("websocket message: $json");
        final jsonMessageType = json["type"];
        final message = json["message"];
        if (jsonMessageType != null && jsonMessageType == messageType) {
          if (message != null && property != null) {
            onMessage(message[property]);
          } else if (message != null) {
            onMessage(message);
          }
        }
      },
      onError: (error) => appLogger.i("websocket error: ${error.description}"),
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

  Future<void> enableScreenShot() {
    return methodChannel.invokeMethod('enableScreenshot', <String, dynamic>{});
  }

  Future<void> disableScreenShot() {
    return methodChannel.invokeMethod('disableScreenshot', <String, dynamic>{});
  }
}
