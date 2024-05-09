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
      onChanges: (setValue) => sessionModel
          .listenWebsocket(websocket, "vpnstatus", "connected", (value) {
        final isConnected = value != null && value.toString() == "true";
        setValue(isConnected ? "connected" : "disconnected");
      }),
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
      onChanges: (setValue) =>
          sessionModel.listenWebsocket(websocket, "bandwidth", null, (value) {
        if (value != null) {
          final Map res = jsonDecode(jsonEncode(value));
          setValue(Bandwidth.create()
            ..mergeFromProto3Json({
              'allowed': res['mibAllowed'],
              'remaining': res['mibUsed'],
            }));
        }
      }),
      null,
      builder: builder,
    );
  }
}
