import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';

typedef void WebsocketChange();

class WebsocketSubscriber {
  static WebsocketSubscriber? _instance;

  final Map<String, List<WebsocketChange>> changeMap = {};

  final vpnStatusNotifier = ValueNotifier("");
  final bandwidthNotifier = ValueNotifier<Bandwidth?>(null);
  final langNotifier = ValueNotifier("en_us");
  final proUserNotifier = ValueNotifier(false);
  final proxyAllNotifier = ValueNotifier(false);
  final userLoggedInNotifier = ValueNotifier(false);
  final serverInfoNotifier = ValueNotifier<ServerInfo?>(null);

  late WebsocketImpl _ws;

  WebsocketSubscriber._internal() {
    _ws = WebsocketImpl.instance()!;
    _ws.messageStream.listen(
      (json) {
        print("websocket message: $json");
        final message = json["message"];
        final messageType = json["type"];
        if (message != null && messageType != null) {
          switch (messageType) {
            case "pro":
              print("pro websocket message: $json");
            case "bandwidth":
              print("bandwidth websocket message: $json");
            case "vpnstatus":
              final res = message["connected"];
              if (res != null) {
                final vpnStatus = res.toString() == "true" ? "connected" : "disconnected"; 
                print("vpn status $vpnStatus");
                vpnStatusNotifier.value = vpnStatus;
              }
          }
        }
      },
      onError: (error) => appLogger.i("websocket error: ${error.description}"),
    );
  }

  Future<void> connect() async => await _ws.connect();

  subscribeUpdates(String messageType, Function() onChanges) {
    if (changeMap[messageType] == null) {
      changeMap[messageType] = [];
    }
    changeMap[messageType]!.add(onChanges);
  }

  unsubscribeUpdates(String messageType) {
    changeMap.removeWhere((key, value) => key == messageType);
  }

  factory WebsocketSubscriber() {
    _instance ??= WebsocketSubscriber._internal();
    return _instance!;
  }
}