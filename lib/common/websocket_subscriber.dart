import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

import 'common.dart';
import 'common_desktop.dart';

var _webSocketLogger = Logger(
  printer: PrettyPrinter(
    printEmojis: true,
    methodCount: 0,
    errorMethodCount: 8,
    colors: true,
  ),
);

enum _WebsocketMessageType {
  config,
  pro,
  bandwidth,
  settings,
  stats,
}

class WebsocketSubscriber {
  static WebsocketSubscriber? _instance;

  late WebsocketImpl _ws;

  WebsocketSubscriber._internal() {
    _ws = WebsocketImpl.instance()!;
    listenMessages();
  }

  Future<void> connect() async => await _ws.connect();

  factory WebsocketSubscriber() {
    _instance ??= WebsocketSubscriber._internal();
    return _instance!;
  }

  void listenMessages() {
    _webSocketLogger.i("Listening to websocket messages");
    _ws.messageStream.listen(
      (json) {
        if (json["type"] == null) return;
        final message = json["message"];
        _WebsocketMessageType? messageType = _WebsocketMessageType.values
            .firstWhereOrNull((e) => e.name == json["type"]);
        if (message == null || messageType == null) return;
        switch (messageType) {
          case _WebsocketMessageType.settings:
            _webSocketLogger.i("websocket message[Setting]: $json");
            final referralCode = message['referralCode'];
            if (referralCode != null)
              sessionModel.referralNotifier.value = referralCode;
            final res = message["disconnected"];
            if (res != null) {
              final vpnStatus =
                  res.toString() == "true" ? "disconnected" : "connected";
              vpnModel.vpnStatusNotifier.value = vpnStatus;
            }
          case _WebsocketMessageType.stats:
            if (message['countryCode'] != null) {
              sessionModel.serverInfoNotifier.value = ServerInfo.create()
                ..mergeFromProto3Json({
                  'city': message['city'],
                  'country': message['country'],
                  'countryCode': message['countryCode'],
                });
            }
          case _WebsocketMessageType.pro:
            _webSocketLogger.i("Websocket message[Pro]: $json");
            final userStatus = message['userStatus'];
            final userLevel = message['userLevel'];
            final deviceLinkingCode = message['deviceLinkingCode'];
            if (userStatus != null &&
                (userStatus == 'active' || userLevel == 'pro')) {
              sessionModel.proUserNotifier.value = true;
            }
            if (deviceLinkingCode != null) sessionModel.linkingCodeNotifier.value = deviceLinkingCode;

          case _WebsocketMessageType.bandwidth:
            _webSocketLogger.i("Websocket message[Bandwidth]: $json");
            final Map res = jsonDecode(jsonEncode(message));
            vpnModel.bandwidthNotifier.value = Bandwidth.create()
              ..mergeFromProto3Json({
                'allowed': res['mibAllowed'],
                'remaining': res['mibUsed'],
              });
          case _WebsocketMessageType.config:
            final ConfigOptions config = ConfigOptions.fromJson(message);
            // Check if auth is enabled
            sessionModel.isAuthEnabled.value = config.authEnabled;
            sessionModel.configNotifier.value = config;
            final plansMessage = config.plans;
            if (plansMessage != null) {
              sessionModel.plansNotifier.value.clearPaths();
              for (String key in plansMessage!.keys) {
                final plan = config.plans?[key];
                if (plan != null) {
                  sessionModel.plansNotifier.value.map[key] = plan;
                }
              }
            }
            final paymentMethods = config.paymentMethods;
            if (paymentMethods != null) {
              sessionModel.paymentMethodsNotifier.value.clearPaths();
              for (String key in paymentMethods!.keys) {
                final paymentMethod = config.paymentMethods?[key];
                if (paymentMethod != null) {
                  sessionModel.paymentMethodsNotifier.value.map[key] =
                      paymentMethod;
                }
              }
            }
        }
      },
      onError: (error) => _webSocketLogger
          .e("websocket error: ${error.description}", error: error),
    );
  }
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
