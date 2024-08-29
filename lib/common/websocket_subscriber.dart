import 'common.dart';
import 'common_desktop.dart';
import 'package:collection/collection.dart';
import 'package:lantern/plans/utils.dart';
import 'package:fixnum/fixnum.dart';

typedef void WebsocketChange();

enum _WebsocketMessageType {
  config,
  pro,
  bandwidth,
  vpnstatus,
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

  listenMessages() =>
    _ws.messageStream.listen(
      (json) {
        if (json["type"] == null) return;
        final message = json["message"];
        _WebsocketMessageType? messageType = _WebsocketMessageType.values.firstWhereOrNull((e) => e.name == json["type"]);
        if (message == null || messageType == null) return;
        switch (messageType) {
          case _WebsocketMessageType.settings:
            print("settings websocket message: $json");
            final referralCode = message['referralCode'];
            if (referralCode != null) sessionModel.referralNotifier.value = referralCode;
          case _WebsocketMessageType.stats:
            if (message['countryCode'] != null) {
              sessionModel.serverInfoNotifier.value = ServerInfo.create()..mergeFromProto3Json({
                'city': message['city'],
                'country': message['country'],
                'countryCode': message['countryCode'],
              });
            }
          case _WebsocketMessageType.pro:
            print("pro websocket message: $message");
            final userStatus = message['userStatus'];
            final userLevel = message['userLevel'];
            if (userStatus != null && userStatus == 'active') sessionModel.proUserNotifier.value = true;
            if (userLevel != null && userLevel == 'pro') sessionModel.proUserNotifier.value = true;
          case _WebsocketMessageType.bandwidth:
            print("bandwidth websocket message: $message");
            final Map res = jsonDecode(jsonEncode(message));
            vpnModel.bandwidthNotifier.value = Bandwidth.create()..mergeFromProto3Json({
              'allowed': res['mibAllowed'],
              'remaining': res['mibUsed'],
            });
          case _WebsocketMessageType.config:
            final ConfigOptions config = ConfigOptions.fromJson(message);
            sessionModel.configNotifier.value = config;
            final plansMessage = config.plans;
            if (plansMessage != null) {
              sessionModel.plansNotifier.value.clearPaths();
              for (String key in plansMessage!.keys) {
                final plan = config.plans?[key];
                if (plan != null) sessionModel.plansNotifier.value.map[key] = plan;
              }
            }
            final paymentMethods = config.paymentMethods;
            if (paymentMethods != null) {
              sessionModel.paymentMethodsNotifier.value.clearPaths();
              for (String key in paymentMethods!.keys) {
                final paymentMethod = config.paymentMethods?[key];
                if (paymentMethod != null) sessionModel.paymentMethodsNotifier.value.map[key] = paymentMethod;
              }
            }
            if (config.authEnabled) sessionModel.isAuthEnabled.value = config.authEnabled;
          case _WebsocketMessageType.vpnstatus:
            final res = message["connected"];
            if (res != null) {
              final vpnStatus = res.toString() == "true" ? "connected" : "disconnected";
              print("vpn status $vpnStatus");
              vpnModel.vpnStatusNotifier.value = vpnStatus;
            }
        }
      },
      onError: (error) => appLogger.i("websocket error: ${error.description}"),
    );

  Future<void> connect() async => await _ws.connect();

  factory WebsocketSubscriber() {
    _instance ??= WebsocketSubscriber._internal();
    return _instance!;
  }
}