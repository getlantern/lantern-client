import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/common/common_desktop.dart';

final vpnModel = VpnModel();

class VpnModel extends Model {
  VpnModel() : super('vpn');

  Future<void> switchVPN<T>(bool on) async {
    return methodChannel.invokeMethod('switchVPN', <String, dynamic>{
      'on': on,
    });
  }

  //This method will create artificial delay in connecting VPN
  // So we can show ads to user
  Future<void> connectingDelay<T>(bool on) async {
    return methodChannel.invokeMethod('connectingDelay', <String, dynamic>{
      'on': on,
    });
  }

  Future<void> handleWebSocketMessage(Map<String, dynamic> data, Function setValue) async {
    if (data["type"] != "vpnstatus") return;
    final updated = data["message"]["connected"];
    final isConnected = updated != null && updated.toString() == "true";
    setValue(isConnected ? "connected" : "disconnected");
  }

  Widget vpnStatus(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        '/vpn_status',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'vpnStatus',
      defaultValue: '',
      onChanges: (setValue) {
        final websocket = WebsocketImpl.instance();
        if (websocket == null) return;
        /// Listen for all incoming data
        websocket.messageStream.listen(
          (json) => handleWebSocketMessage(json, setValue),
          onError: (error) => print(error),
        );
      },
      ffiVpnStatus,
      builder: builder,
    );
  }
 
  Future<bool> isVpnConnected() async {
    final vpnStatus = await methodChannel.invokeMethod('getVpnStatus');
    return vpnStatus == 'connected';
  }

  Widget bandwidth(ValueWidgetBuilder<Bandwidth> builder) {
    return subscribedSingleValueBuilder<Bandwidth>(
      '/bandwidth',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return Bandwidth.fromBuffer(serialized);
      },
    );
  }
}
