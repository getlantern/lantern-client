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
    isPlayVersion = singleValueNotifier(
      'playVersion',
      false,
    );
    proxyAvailable = singleValueNotifier(
      'hasSucceedingProxy',
      true,
    );
  }

  ValueNotifier<bool> networkAvailable = ValueNotifier(true);
  late ValueNotifier<bool?> isPlayVersion;
  late ValueNotifier<bool?> proxyAvailable;

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

  Future<void> setProxyAll<T>(bool on) async {
    unawaited(
      methodChannel.invokeMethod('setProxyAll', <String, dynamic>{
        'on': on,
      }),
    );
  }

  Future<void> setLanguage(String lang) {
    return methodChannel.invokeMethod('setLanguage', <String, dynamic>{
      'lang': lang,
    });
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

  Future<String> approveDevice(String code) {
    return methodChannel.invokeMethod('approveDevice', <String, dynamic>{
      'code': code,
    }).then((value) => value as String);
  }

  Future<void> removeDevice(String deviceId) {
    return methodChannel.invokeMethod('removeDevice', <String, dynamic>{
      'deviceId': deviceId,
    });
  }

  Future<void> resendRecoveryCode() {
    return methodChannel
        .invokeMethod('resendRecoveryCode', <String, dynamic>{});
  }

  Future<void> setSelectedTab<T>(String tab) async {
    return methodChannel.invokeMethod('setSelectedTab', <String, dynamic>{
      'tab': tab,
    });
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

  Future<void> redeemResellerCode(
    String email,
    String resellerCode,
  ) async {
    return methodChannel.invokeMethod('redeemResellerCode', <String, dynamic>{
      'email': email,
      'resellerCode': resellerCode,
    }).then((value) => value as String);
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
}
