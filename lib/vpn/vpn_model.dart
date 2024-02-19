import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/common/common_desktop.dart' as desktop;

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
    if (Platform.isAndroid) {
      return subscribedSingleValueBuilder<String>(
        '/vpn_status',
        builder: builder,
      );
    }
    return ffiValueBuilder<String>(
      'vpnStatus',
      defaultValue: '',
      desktop.vpnStatus,
      builder: builder,
    );
  }

  Future<bool> isVpnConnected() async {
    final vpnStatus = await methodChannel.invokeMethod('getVpnStatus');
    return vpnStatus == 'connected';
  }

  //This method has moved to Session model
  // Due to go model changes
  // Widget serverInfo(ValueWidgetBuilder<ServerInfo> builder) {
  //   return subscribedSingleValueBuilder<ServerInfo>(
  //     '/server_info',
  //     builder: builder,
  //     deserialize: (Uint8List serialized) {
  //       return ServerInfo.fromBuffer(serialized);
  //     },
  //   );
  // }

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
