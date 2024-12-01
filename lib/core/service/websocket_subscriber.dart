import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

import '../utils/common.dart';
import '../utils/common_desktop.dart';

var _webSocketLogger = Logger(
  level: Level.all,
  filter: DevelopmentFilter(),
  output: ConsoleOutput(),
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

  Future<void> connect() async => await _ws.connect();

  factory WebsocketSubscriber() {
    _instance ??= WebsocketSubscriber._internal();
    return _instance!;
  }

  void listenMessages() {
    _webSocketLogger.i("Listening to websocket messages");
    _ws.messageStream.listen(
      (json) {
        _webSocketLogger.d("websocket message: $json");
        if (json["type"] == null) return;
        final message = json["message"];
        _WebsocketMessageType? messageType = _WebsocketMessageType.values
            .firstWhereOrNull((e) => e.name == json["type"]);
        if (message == null || messageType == null) return;
        switch (messageType) {
          case _WebsocketMessageType.settings:
            _webSocketLogger.i("websocket message[Setting]: $json");
            final referralCode = message['referralCode'];
            if (referralCode != null) {
              sessionModel.referralNotifier.value = referralCode;
            }
            final emailAddresses = message['emailAddress'];
            if (emailAddresses != null) {
              sessionModel.userEmail.value = emailAddresses;
            }

            final deviceID = message['deviceID'];
            if (deviceID != null) {
              sessionModel.deviceIdNotifier.value = deviceID;
            }

            final proxyAll = message['proxyAll'];
            if (proxyAll != null) {
              sessionModel.proxyAllNotifier.value = proxyAll as bool;
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
            _webSocketLogger.i("Websocket message[Pro]: $message");
            final userStatus = message['userStatus'];
            final userLevel = message['userLevel'];
            final deviceLinkingCode = message['deviceLinkingCode'];
            if (userLevel != null) {
              if (userLevel == 'pro' || userStatus == 'active') {
                sessionModel.proUserNotifier.value = true;
              } else {
                sessionModel.proUserNotifier.value = false;
              }
            }
            if (deviceLinkingCode != null) {
              sessionModel.linkingCodeNotifier.value = deviceLinkingCode;
            }
            final userSignedIn = message['login'];
            if (userSignedIn != null) {
              sessionModel.hasUserSignedInNotifier.value = userSignedIn as bool;
            }
            final language = message['language'];
            if (language != null) {
              sessionModel.langNotifier.value = language;
            }

          case _WebsocketMessageType.bandwidth:
            _webSocketLogger.i("Websocket message[Bandwidth]: $message");
            sessionModel.bandwidthNotifier.value = Bandwidth.create()
              ..mergeFromProto3Json(message);
          case _WebsocketMessageType.config:
            _webSocketLogger.i("Websocket message[config]: $message");
            final ConfigOptions config = ConfigOptions.fromJson(message);

            sessionModel.isAuthEnabled.value = config.authEnabled;
            sessionModel.configNotifier.value = config;
            _updatePlans(config.plans);
            _updatePaymentMethods(config.paymentMethods);
            break;

          case _WebsocketMessageType.vpnstatus:
            final res = message["connected"];
            if (res != null) {
              final vpnStatus =
                  res.toString() == "true" ? "connected" : "disconnected";
              _webSocketLogger.i("Websocket message[VPNStatus]: $vpnStatus");
            }
            break;
        }
      },
      onError: (error) => _webSocketLogger
          .e("websocket error: ${error.description}", error: error),
    );
  }
}

/// Method to update plans
void _updatePlans(Map<String, Plan>? plans) {
  if (plans != null) {
    sessionModel.plansNotifier.value.clearPaths();
    plans.forEach((key, plan) {
      sessionModel.plansNotifier.value.map[key] = plan;
    });
  }
}

// Method to update payment methods
void _updatePaymentMethods(Map<String, PaymentMethod>? paymentMethods) {
  if (paymentMethods != null) {
    sessionModel.paymentMethodsNotifier.value.clearPaths();
    paymentMethods.forEach((key, paymentMethod) {
      if (paymentMethod != null) {
        sessionModel.paymentMethodsNotifier.value.map[key] = paymentMethod;
      }
    });
  }
}
