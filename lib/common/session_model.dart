import 'common.dart';

final sessionModel = SessionModel();

class SessionModel extends Model {
  SessionModel() : super('session');

  Widget proUser(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('prouser', builder: builder);
  }

  Widget proxyAll(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('proxyAll', builder: builder);
  }

  Widget developmentMode(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('developmentMode',
        builder: builder);
  }

  Widget paymentTestMode(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('paymentTestMode',
        builder: builder);
  }

  Future<void> setPaymentTestMode(bool on) {
    return methodChannel.invokeMethod('setPaymentTestMode', <String, dynamic>{
      'on': on,
    });
  }

  Widget forceCountry(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('forceCountry',
        builder: builder);
  }

  Future<void> setForceCountry(String? countryCode) {
    return methodChannel.invokeMethod('setForceCountry', <String, dynamic>{
      'countryCode': countryCode,
    });
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
    return subscribedSingleValueBuilder<String>('emailAddress',
        builder: builder);
  }

  Widget expiryDate(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('expirydatestr',
        builder: builder);
  }

  Widget deviceId(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('deviceid', builder: builder);
  }

  Widget devices(ValueWidgetBuilder<Devices> builder) {
    return subscribedSingleValueBuilder<Devices>('devices', builder: builder,
        deserialize: (Uint8List serialized) {
      return Devices.fromBuffer(serialized);
    });
  }

  Future<void> setProxyAll<T>(bool on) async {
    unawaited(methodChannel.invokeMethod('setProxyAll', <String, dynamic>{
      'on': on,
    }));
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

  Future<void> setTabIndex<T>(int tabIndex) async {
    return methodChannel.invokeMethod('setTabIndex', <String, dynamic>{
      'tabIndex': tabIndex,
    });
  }

  Widget tabIndex(ValueWidgetBuilder<int> builder) {
    return subscribedSingleValueBuilder<int>('/tabIndex',
        defaultValue: 0, builder: builder);
  }
}
