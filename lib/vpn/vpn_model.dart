import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/vpn/vpn.dart';

final vpnModel = VpnModel();

class VpnModel extends Model {
  late ValueNotifier<String> vpnStatusNotifier;

  VpnModel() : super('vpn') {}

  Future<void> switchVPN<T>(bool on) async {
    return methodChannel.invokeMethod('switchVPN', <String, dynamic>{
      'on': on,
    });
  }

  bool isConnected() => vpnStatusNotifier.value == 'connected';

  void toggleVpn() {
    final newStatus = isConnected() ? 'disconnected' : 'connected';
    vpnStatusNotifier.value = newStatus;
  }

  //This method will create artificial delay in connecting VPN
  // So we can show ads to user
  Future<void> connectingDelay<T>(bool on) async {
    return methodChannel.invokeMethod('connectingDelay', <String, dynamic>{
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
    final vpnStatus = await methodChannel.invokeMethod('getVpnStatus', {});
    return vpnStatus == 'connected';
  }
}
