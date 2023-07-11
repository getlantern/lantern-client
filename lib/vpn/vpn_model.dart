import 'package:lantern/vpn/vpn.dart';

final vpnModel = VpnModel();

class VpnModel extends Model {
  VpnModel() : super('vpn');

  Future<void> switchVPN<T>(bool on) async {
    return methodChannel.invokeMethod('switchVPN', <String, dynamic>{
      'on': on,
    });
  }

  Widget vpnStatus(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>(
      '/vpn_status',
      builder: builder,
    );
  }

  Future<bool> isVpnConnected() async {
    final vpnStatus = await methodChannel.invokeMethod('get', '/vpn_status');
    return vpnStatus == 'connected';
  }

  Widget serverInfo(ValueWidgetBuilder<ServerInfo> builder) {
    return subscribedSingleValueBuilder<ServerInfo>(
      '/server_info',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return ServerInfo.fromBuffer(serialized);
      },
    );
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
