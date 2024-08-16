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
}

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
  final plansNotifier = FfiListNotifier<Plan>('/plans/', LanternFFI.plans, planFromJson, () => {});

  late WebsocketImpl _ws;

  WebsocketSubscriber._internal() {
    _ws = WebsocketImpl.instance()!;
    _ws.messageStream.listen(
      (json) {
        if (json["type"] == null) return;
        print("websocket message: $json");
        final message = json["message"];
        WebsocketMessage? messageType = WebsocketMessage.values.firstWhereOrNull((e) => e.name == json["type"]);
        if (message != null && messageType != null) {
          switch (messageType) {
            case WebsocketMessage.pro:
              print("pro websocket message: $json");
            case WebsocketMessage.bandwidth:
              print("bandwidth websocket message: $json");
            case WebsocketMessage.vpnstatus:
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