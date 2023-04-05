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
    proxyAvailable = singleValueNotifier(
      'hasSucceedingProxy',
      true,
    );
  }

  ValueNotifier<bool> networkAvailable = ValueNotifier(true);
  late ValueNotifier<bool?> proxyAvailable;

  Widget proUser(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('prouser', builder: builder);
  }

  Widget proxyAll(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('proxyAll', builder: builder);
  }

  Widget splitTunneling(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('splitTunneling', builder: builder);
  }


  Future<void> setSplitTunneling<T>(bool on) async {
    unawaited(methodChannel.invokeMethod('setSplitTunneling', <String, dynamic>{
      'on': on,
    }));
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

  Future<AppsData> appsData() {
    return methodChannel
        .invokeMethod('get', 'appsData')
        .then((value) => AppsData.fromBuffer(value as Uint8List));
  }

  ValueNotifier<AppsData?> appsDataNotifier() {
    return singleValueNotifier(
      'appsData',
      null,
      deserialize: (Uint8List serialized) {
        return AppsData.fromBuffer(serialized);
      },
    );
  }

  Future<void> addExcludedApp(String packageName) {
    return methodChannel.invokeMethod('addExcludedApp', <String, dynamic>{
      'packageName': packageName,
    });
  }

  Future<void> removeExcludedApp(String packageName) {
    return methodChannel.invokeMethod('removeExcludedApp', <String, dynamic>{
      'packageName': packageName,
    });
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

  Future<void> trackScreenView(String path) async {
    return methodChannel.invokeMethod('trackScreenView', path);
  }

  Future<void> checkForUpdates() {
    return methodChannel.invokeMethod('checkForUpdates');
  }
}
