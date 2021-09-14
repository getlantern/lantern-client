import 'package:lantern/vpn/vpn.dart';

class VpnModel extends Model {
  VpnModel() : super('vpn');

  Future<void> switchVPN<T>(bool on) async {
    return methodChannel.invokeMethod('switchVPN', <String, dynamic>{
      'on': on,
    });
  }

  Widget vpnStatus(ValueWidgetBuilder<String> builder) {
    return subscribedSingleValueBuilder<String>('/vpn_status',
        builder: builder);
  }

  Widget serverInfo(ValueWidgetBuilder<ServerInfo> builder) {
    return subscribedSingleValueBuilder<ServerInfo>('/server_info',
        builder: builder, deserialize: (Uint8List serialized) {
      return ServerInfo.fromBuffer(serialized);
    });
  }

  Widget bandwidth(ValueWidgetBuilder<Bandwidth> builder) {
    return subscribedSingleValueBuilder<Bandwidth>('/bandwidth',
        builder: builder, deserialize: (Uint8List serialized) {
      return Bandwidth.fromBuffer(serialized);
    });
  }
}
