import 'package:lantern/core/utils/utils.dart';

import 'common.dart';

extension BoolParsing on String {
  bool parseBool() {
    return toLowerCase() == 'true';
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
  final bool isUserLoggedIn;
  final bool fetchedGlobalConfig;
  final bool fetchedProxiesConfig;

  // final String appVersion;
  final String sdkVersion;
  final String deviceId;
  final String expirationDate;
  final String httpProxyAddr;
  final String socksProxyAddr;

  final Map<String, Plan>? plans;
  Devices devices = Devices();

  final Map<String, PaymentMethod>? paymentMethods;
  final _ChatOptions chat;
  final String country;

  ConfigOptions({
    this.developmentMode = false,
    this.replicaAddr = '',
    this.authEnabled = false,
    this.chatEnabled = false,
    this.splitTunneling = false,
    this.hasSucceedingProxy = false,
    this.fetchedGlobalConfig = false,
    this.fetchedProxiesConfig = false,
    this.isUserLoggedIn = false,
    this.expirationDate = '',
    this.sdkVersion = '',
    this.httpProxyAddr = '',
    this.socksProxyAddr = '',
    this.deviceId = '',
    this.plans,
    this.paymentMethods,
    required this.devices,
    this.chat = const _ChatOptions(),
    required this.country,
  });

  bool get startupReady =>
      hasSucceedingProxy && fetchedGlobalConfig && fetchedProxiesConfig;

  factory ConfigOptions.fromJson(Map<String, dynamic> parsedJson) {
    final Map<String, Plan> plans = {};
    final plansResponse = parsedJson['plans'];
    if (plansResponse is List<dynamic>) {
      for (var item in plansResponse) {
        var id = item['id'] ?? item['name'];
        plans[id] = planFromJson(item);
      }
    }
    final paymentMethods = paymentMethodsFromJson(parsedJson['paymentMethods']);

    return ConfigOptions(
      developmentMode: parsedJson['developmentMode'] ?? false,
      authEnabled: parsedJson['authEnabled'] ?? false,
      isUserLoggedIn: parsedJson['isUserLoggedIn'] ?? false,
      chatEnabled: parsedJson['chatEnabled'] ?? false,
      httpProxyAddr: parsedJson['httpProxyAddr'] ?? '',
      socksProxyAddr: parsedJson['socksProxyAddr'] ?? '',
      splitTunneling: parsedJson['splitTunneling'] ?? false,
      hasSucceedingProxy: parsedJson['hasSucceedingProxy'] ?? false,
      fetchedGlobalConfig: parsedJson['fetchedGlobalConfig'] ?? false,
      fetchedProxiesConfig: parsedJson['fetchedProxiesConfig'] ?? false,
      plans: plans,
      chat: _ChatOptions.fromJson(parsedJson['chat'] ?? const _ChatOptions()),
      paymentMethods: paymentMethods,
      devices: _parseDevices(parsedJson),
      replicaAddr: parsedJson['replicaAddr'] ?? '',
      deviceId: parsedJson['deviceId'] ?? '',
      expirationDate: parsedJson['expirationDate'] ?? '',
      sdkVersion: parsedJson['sdkVersion'] ?? '',
      country: parsedJson['country'] ?? '',
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
