import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/features/vpn/vpn.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:lantern/features/vpn/vpn_status.dart';

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

  Widget vpnStatus(BuildContext context, ValueWidgetBuilder<String> builder) {
    if (isDesktop()) {
      final notifier = context.read<VPNChangeNotifier>();
      return ValueListenableBuilder<String>(
        valueListenable: notifier.vpnStatus,
        builder: (context, vpnStatus, child) {
          return builder(context, vpnStatus, child);
        },
      );
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
