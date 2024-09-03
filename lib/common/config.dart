import 'package:lantern/plans/utils.dart';

import 'common.dart';

extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}

class _ChatOptions {
  final bool onBoardingStatus;
  final int acceptedTermsVersion;

  const _ChatOptions({
    this.onBoardingStatus = false,
    this.acceptedTermsVersion = 0,
  });

  factory _ChatOptions.fromJson(Map<String, dynamic> parsedJson) {
    return _ChatOptions(
      onBoardingStatus: parsedJson['onBoardingStatus'],
      acceptedTermsVersion: parsedJson['acceptedTermsVersion'],
    );
  }
}

class ConfigOptions {
  final bool developmentMode;
  final String replicaAddr;
  final bool authEnabled;
  final bool chatEnabled;
  final bool splitTunneling;
  final bool hasSucceedingProxy;
  final bool fetchedGlobalConfig;
  final bool fetchedProxiesConfig;

  // final String appVersion;
  final String sdkVersion;
  final String deviceId;
  final String expirationDate;

  final Map<String, Plan>? plans;
  Devices devices = Devices();

  final Map<String, PaymentMethod>? paymentMethods;
  final _ChatOptions chat;

  ConfigOptions({
    this.developmentMode = false,
    this.replicaAddr = '',
    this.authEnabled = false,
    this.chatEnabled = false,
    this.splitTunneling = false,
    this.hasSucceedingProxy = false,
    this.fetchedGlobalConfig = false,
    this.fetchedProxiesConfig = false,
    this.expirationDate = '',
    this.sdkVersion = '',
    this.deviceId = '',
    this.plans = null,
    this.paymentMethods = null,
    required this.devices,
    this.chat = const _ChatOptions(),
  });

  bool get startupReady =>
      hasSucceedingProxy && fetchedGlobalConfig && fetchedProxiesConfig;

  factory ConfigOptions.fromJson(Map<String, dynamic> parsedJson) {
    final Map<String, Plan> plans = {};
    final plansResponse = parsedJson['plans'];
    if (plansResponse is List<dynamic>) {
      for (var item in plansResponse) {
        var id = item['id'] ?? item['name'];
        plans[id] = planFromJson(item) as Plan;
      }
    }
    final paymentMethods = paymentMethodsFromJson(parsedJson['paymentMethods']);

    return ConfigOptions(
      developmentMode: parsedJson['developmentMode'],
      authEnabled: parsedJson['authEnabled'],
      chatEnabled: parsedJson['chatEnabled'],
      splitTunneling: parsedJson['splitTunneling'],
      hasSucceedingProxy: parsedJson['hasSucceedingProxy'],
      fetchedGlobalConfig: parsedJson['fetchedGlobalConfig'],
      fetchedProxiesConfig: parsedJson['fetchedProxiesConfig'],
      plans: plans,
      chat: _ChatOptions.fromJson(parsedJson['chat']),
      paymentMethods: paymentMethods,
      devices: _parseDevices(parsedJson),
      replicaAddr: parsedJson['replicaAddr'].toString(),
      deviceId: parsedJson['deviceId'].toString(),
      expirationDate: parsedJson['expirationDate'].toString(),
      sdkVersion: parsedJson['sdkVersion'].toString(),
    );
  }

  static Devices _parseDevices(Map json) {
    final deviceObj = json['devices'] as Map;
    final devices = Devices();
    if (deviceObj.values.isNotEmpty) {
      final deviceList = deviceObj['devices'] as List;
      for (var device in deviceList) {
        final protoDevice = Device.create()..mergeFromProto3Json(device);
        devices.devices.add(protoDevice);
      }
    }
    return devices;
  }
}
