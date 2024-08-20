import 'common.dart';
import 'common_desktop.dart';
import 'package:collection/collection.dart';
import 'package:lantern/plans/utils.dart';
import 'package:fixnum/fixnum.dart';

typedef void WebsocketChange();

enum WebsocketMessage {
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
        WebsocketMessage? messageType = WebsocketMessage.values.firstWhereOrNull((e) => e.name == json["type"]);
        if (message == null || messageType == null) return;
        switch (messageType) {
          case WebsocketMessage.settings:
            print("settings websocket message: $json");
            final referralCode = message['referralCode'];
            if (referralCode != null) sessionModel.referralNotifier.value = referralCode;
          case WebsocketMessage.stats:
            if (message['countryCode'] != null) {
              sessionModel.serverInfoNotifier.value = ServerInfo.create()..mergeFromProto3Json({
                'city': message['city'],
                'country': message['country'],
                'countryCode': message['countryCode'],
              });
            }
          case WebsocketMessage.pro:
            print("pro websocket message: $json");
          case WebsocketMessage.bandwidth:
            print("bandwidth websocket message: $json");
            final Map res = jsonDecode(jsonEncode(json));
            vpnModel.bandwidthNotifier.value = Bandwidth.create()..mergeFromProto3Json({
              'allowed': res['mibAllowed'],
              'remaining': res['mibUsed'],
            });
          case WebsocketMessage.vpnstatus:
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