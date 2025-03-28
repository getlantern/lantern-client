import 'package:lantern/core/service/websocket.dart';
import 'package:lantern/core/utils/config.dart';
import 'package:lantern/features/home/session_model.dart';
import 'package:lantern/features/vpn/protos_shared/vpn.pb.dart';
import 'package:logger/logger.dart';

final _webSocketLogger = Logger(
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
  stats
}

class WebsocketSubscriber {
  static WebsocketSubscriber? _instance;
  late final WebsocketImpl _ws;

  WebsocketSubscriber._internal() {
    _ws = WebsocketImpl.instance()!;
    _listenMessages();
  }

  factory WebsocketSubscriber() =>
      _instance ??= WebsocketSubscriber._internal();

  Future<void> connect() async => await _ws.connect();

  void _listenMessages() {
    _webSocketLogger.i("Listening to WebSocket messages");

    _ws.messageStream.listen(
      _handleMessage,
      onError: (error) => _webSocketLogger
          .e("WebSocket error: ${error.description}", error: error),
    );
  }

  void _handleMessage(Map<String, dynamic> json) {
    final type = json["type"] as String?;
    final message = json["message"];

    if (type == null || message == null) return;

    final messageType = _WebsocketMessageType.values.firstWhere(
      (e) => e.name == type,
    );

    _webSocketLogger.d("WebSocket message [$type]: $message");

    switch (messageType) {
      case _WebsocketMessageType.settings:
        _handleSettings(message);
        break;
      case _WebsocketMessageType.stats:
        _handleStats(message);
        break;
      case _WebsocketMessageType.pro:
        _handlePro(message);
        break;
      case _WebsocketMessageType.bandwidth:
        _handleBandwidth(message);
        break;
      case _WebsocketMessageType.config:
        _handleConfig(message);
        break;
      case _WebsocketMessageType.vpnstatus:
        _handleVpnStatus(message);
        break;
    }
  }

  void _handleSettings(Map<String, dynamic> message) {
    sessionModel.userEmail.value =
        message['emailAddress'] ?? sessionModel.userEmail.value;
    sessionModel.proxyAllNotifier.value =
        (message['proxyAll'] as bool?) ?? sessionModel.proxyAllNotifier.value;
    sessionModel.proUserNotifier.value =
        message['userPro']?.toString() == 'true';
  }

  void _handleStats(Map<String, dynamic> message) {
    if (message['countryCode'] != null) {
      sessionModel.serverInfoNotifier.value = ServerInfo.create()
        ..mergeFromProto3Json({
          'city': message['city'],
          'country': message['country'],
          'countryCode': message['countryCode'],
        });
    }
  }

  void _handlePro(Map<String, dynamic> message) {
    sessionModel.linkingCodeNotifier.value =
        message['deviceLinkingCode'] ?? sessionModel.linkingCodeNotifier.value;
    sessionModel.hasUserSignedInNotifier.value =
        message['login'] as bool? ?? sessionModel.hasUserSignedInNotifier.value;
    sessionModel.langNotifier.value =
        message['language'] ?? sessionModel.langNotifier.value;
  }

  void _handleBandwidth(Map<String, dynamic> message) {
    sessionModel.bandwidthNotifier.value = Bandwidth.create()
      ..mergeFromProto3Json(message);
  }

  void _handleConfig(Map<String, dynamic> message) {
    final config = ConfigOptions.fromJson(message);

    sessionModel.isAuthEnabled.value = config.authEnabled;
    sessionModel.configNotifier.value = config;
    sessionModel.country.value = config.country;

    _updatePlans(config.plans);
    _updatePaymentMethods(config.paymentMethods);
  }

  void _handleVpnStatus(Map<String, dynamic> message) {
    final vpnStatus = (message["connected"]?.toString() == "true")
        ? "connected"
        : "disconnected";
    _webSocketLogger.i("WebSocket message [VPNStatus]: $vpnStatus");
  }
}

void _updatePlans(Map<String, Plan>? plans) {
  if (plans == null) return;
  sessionModel.plansNotifier.value.clearPaths();
  sessionModel.plansNotifier.value.map.addAll(plans);
}

void _updatePaymentMethods(Map<String, PaymentMethod>? paymentMethods) {
  if (paymentMethods == null) return;
  sessionModel.paymentMethodsNotifier.value.clearPaths();
  sessionModel.paymentMethodsNotifier.value.map.addAll(paymentMethods);
}
