import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/features/vpn/vpn.dart';

final vpnModel = VpnModel();

class VpnModel extends Model {
  late ValueNotifier<String> vpnStatusNotifier;

  VpnModel() : super('vpn') {
    if (isDesktop()) {
      vpnStatusNotifier = ValueNotifier("disconnected");
    }
  }

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
    return FfiValueBuilder<String>('vpnStatus', vpnStatusNotifier, builder);
  }

  Future<bool> isVpnConnected() async {
    final vpnStatus = await methodChannel.invokeMethod('getVpnStatus', {});
    return vpnStatus == 'connected';
  }
}
