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

    if (Platform.isAndroid) {
      // By default when user starts the app we need to make sure that screenshot is disabled
      // if user goes to chat then screenshot will be disabled
      enableScreenShot();
    }
  }

  ValueNotifier<bool> networkAvailable = ValueNotifier(true);
  late ValueNotifier<bool?> isPlayVersion;
  late ValueNotifier<bool?> isStoreVersion;
  late ValueNotifier<bool?> proxyAvailable;
  late ValueNotifier<String?> country;

  // listenWebsocket listens for websocket messages from the server. If a message matches the given message type,
  // the onMessage callback is triggered with the given property value
  void listenWebsocket<T>(WebsocketImpl? websocket, String messageType,
      String? property, void Function(T?) onMessage) {
    if (websocket == null) return;
    websocket.messageStream.listen(
      (json) {
        if (json["type"] == messageType) {
          if (property != null) {
            onMessage(json["message"][property]);
          } else {
            onMessage(json["message"]);
          }
        }
      },
      onError: (error) => appLogger.i("websocket error: ${error.description}"),
    );
  }

  Widget proUser(ValueWidgetBuilder<bool> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<bool>('prouser', builder: builder);
    }
    final websocket = WebsocketImpl.instance();
    return ffiValueBuilder<bool>(
      'prouser',
      defaultValue: false,
      onChanges: (setValue) =>
          listenWebsocket(websocket, "pro", "userStatus", (value) {
        if (value != null && value.toString() == "active") setValue(true);
      }),
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
    final websocket = WebsocketImpl.instance();
    return ffiValueBuilder<String>(
      'lang',
      defaultValue: 'en',
      onChanges: (setValue) =>
          listenWebsocket(websocket, "pro", "language", (value) {
        if (value != null && value.toString() != "") setValue(value.toString());
      }),
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
      'expirydatestr',
      ffiExpiryDate,
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
      'deviceid',
      ffiReferral,
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
      ffiDevices,
      fromJsonModel: devicesFromJson,
      defaultValue: null,
      builder: builder,
    );
  }

  Future<void> setProxyAll<T>(bool isOn) async {
    if (isDesktop()) {
      return await compute(ffiSetProxyAll, isOn ? 'true' : 'false');
    }
    throw Exception("Not supported on mobile");
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
    Localization.locale = lang;
    final newLang = lang.toNativeUtf8();
    setLang(newLang);
    return Future(() => null);
  }

  Future<String> authorizeViaEmail(String emailAddress) {
    return methodChannel.invokeMethod('authorizeViaEmail', <String, dynamic>{
      'emailAddress': emailAddress,
    }).then((value) => value as String);
  }

  Future<String> validateRecoveryCode(String code) {
    return methodChannel.invokeMethod('validateRecoveryCode', <String, dynamic>{
      'code': code,
    }).then((value) => value as String);
  }

  Future<String> approveDevice(String code) async {
    if (isMobile()) {
      return methodChannel.invokeMethod('approveDevice', <String, dynamic>{
        'code': code,
      }).then((value) => value as String);
    }
    return await compute(ffiApproveDevice, code);
  }

  Future<void> removeDevice(String deviceId) async {
    if (isMobile()) {
      return methodChannel.invokeMethod('removeDevice', <String, dynamic>{
        'deviceId': deviceId,
      });
    }
    return await compute(ffiRemoveDevice, deviceId);
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

  // Plans and payment methods
  Future<void> updatePaymentPlans() async {
    return methodChannel.invokeMethod('updatePaymentPlans');
  }

  Future<bool> hasUpdatePlansOrBuy() async {
    return compute(ffiHasPlanUpdateOrBuy, '');
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
      return await compute(ffiReportIssue, [email, issue, description]);
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
      fromJsonModel: (dynamic json) {
        final res = jsonEncode(json);
        return ServerInfo.create()..mergeFromProto3Json(jsonDecode(res));
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
    if (isMobile()) {
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
      ffiDeviceLinkingCode,
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
      }).then((value) {
        print('value $value');
      });
    }
    ffiRedeemResellerCode(email.toNativeUtf8(), currency.toNativeUtf8(),
        deviceName.toNativeUtf8(), resellerCode.toNativeUtf8());
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
      String email, String provider) async {
    String os = Platform.operatingSystem;
    Locale locale = Localizations.localeOf(context);
    final format = NumberFormat.simpleCurrency(locale: locale.toString());
    final currencyName = format.currencyName ?? "USD";
    return await compute(
        ffiPaymentRedirect, [planID, currencyName, provider, email, os]);
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
    await compute(ffiEmailExists, email);
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
