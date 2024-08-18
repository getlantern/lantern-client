import 'package:lantern/common/ffi_subscriber.dart';
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
    final notifier = WebsocketSubscriber.vpnStatusNotifier;
    return FfiValueBuilder<String>('vpnStatus', notifier, builder);
  }

  Future<bool> isVpnConnected() async {
    final vpnStatus = await methodChannel.invokeMethod('getVpnStatus');
    return vpnStatus == 'connected';
  }

  Widget bandwidth(ValueWidgetBuilder<Bandwidth?> builder) {
    if (isMobile()) {
      return subscribedSingleValueBuilder<Bandwidth?>(
        '/bandwidth',
        builder: builder,
        deserialize: (Uint8List serialized) {
          return Bandwidth.fromBuffer(serialized);
        },
      );
    }
    final notifier = WebsocketSubscriber.bandwidthNotifier;
    return FfiValueBuilder<Bandwidth?>('bandwidth', notifier, builder);
  }
}
