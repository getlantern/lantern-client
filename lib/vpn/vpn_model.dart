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

  Widget splitTunneling(ValueWidgetBuilder<bool> builder) {
    return subscribedSingleValueBuilder<bool>('/splitTunneling',
        builder: builder,);
  }

  Future<void> setSplitTunneling<T>(bool on) async {
    unawaited(methodChannel.invokeMethod('setSplitTunneling', <String, dynamic>{
      'on': on,
    }),);
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

  Widget appsData({
    required ValueWidgetBuilder<Iterable<PathAndValue<AppData>>> builder,
  }) {
    return subscribedListBuilder<AppData>(
      '/appsData/',
      builder: builder,
      deserialize: (Uint8List serialized) {
        return AppData.fromBuffer(serialized);
      },
    );
  }

  Future<void> addExcludedApp(String packageName) {
    return methodChannel.invokeMethod('addExcludedApp', <String, dynamic>{
      'packageName': packageName,
    });
  }

  Future<void> removeExcludedApp(String packageName) {
    return methodChannel.invokeMethod('removeExcludedApp', <String, dynamic>{
      'packageName': packageName,
    });
  }
}
