import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/vpn/vpn_notifier.dart';

final vpnModel = VpnModel();

class VpnModel extends Model {
  VpnModel() : super('vpn') {}

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

  Widget vpnStatus(BuildContext context, ValueWidgetBuilder<String> builder) {
    if (isDesktop()) {
      final vpnNotifier = context.watch<VPNChangeNotifier>();
      return FfiValueBuilder<String>(
          'vpnStatus', vpnNotifier.vpnStatus, builder);
    }
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
