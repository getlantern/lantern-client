import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/common/common_desktop.dart' as desktop;
import 'package:lantern/flutter_go.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
    final channel = WebSocketChannel.connect(
      Uri.parse("ws://" + desktop.websocketAddr() + '/data'),
    );
    return ffiValueBuilder<String>(
      'vpnStatus',
      defaultValue: '',
      channel: channel,
      onChanges: (setValue) {
        /// Listen for all incoming data
        channel.stream.listen(
          (data) {
            final parsedJson = json.decode(data);
            if (parsedJson["type"] == "sysproxy") {
              final updated = parsedJson["message"]["connected"];
              final isConnected = updated != null && updated.toString() == "true";
              setValue(isConnected ? "connected" : "disconnected");
            }
          },
          onError: (error) => print(error),
        );
      },
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
