import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/vpn/vpn.dart';

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

  Widget vpnStatus(ValueWidgetBuilder<String> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<String>(
        '/vpn_status',
        builder: builder,
      );
    }
    final websocket = WebsocketImpl.instance();
    return ffiValueBuilder<String>(
      'vpnStatus',
      defaultValue: '',
      onChanges: (setValue) => {
      websocket?.addMessageCallback("pro", (_, json) {
          if (json["pro"] != null && json["vpnstatus"]["connected"] != null) {
            var value = json["pro"]["userStatus"];
            final isConnected = value != null && value.toString() == "true";
            if (value != null && value.toString() == "true") setValue(isConnected ? "connected" : "disconnected");
          }
        })},
      ffiVpnStatus,
      builder: builder,
    );
  }

  Future<bool> isVpnConnected() async {
    final vpnStatus = await methodChannel.invokeMethod('getVpnStatus');
    return vpnStatus == 'connected';
  }

  Widget bandwidth(ValueWidgetBuilder<Bandwidth> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<Bandwidth>(
        '/bandwidth',
        builder: builder,
        deserialize: (Uint8List serialized) {
          return Bandwidth.fromBuffer(serialized);
        },
      );
    }
    final websocket = WebsocketImpl.instance();
    return ffiValueBuilder<Bandwidth>(
      'bandwidth',
      defaultValue: null,
      onChanges: (setValue) {
          websocket?.addMessageCallback("bandwidth", (_, json) {
            final Map res = jsonDecode(jsonEncode(json));
            setValue(Bandwidth.create()
              ..mergeFromProto3Json({
                'allowed': res['mibAllowed'],
                'remaining': res['mibUsed'],
              }));
          });
      },
      null,
      builder: builder,
    );
  }
}
