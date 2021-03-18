import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos/vpn.pb.dart';

import '../package_store.dart';

class VpnModel extends Model {
  VpnModel() : super("vpn");

  Future<void> switchVPN<T>(bool on) async {
    methodChannel.invokeMethod('switchVPN', <String, dynamic>{
      "on": on,
    });
  }

  ValueListenableBuilder<String> vpnStatus(ValueWidgetBuilder<String> builder) {
    return subscribedBuilder<String>("/vpn_status", builder: builder);
  }

  ValueListenableBuilder<ServerInfo> serverInfo(
      ValueWidgetBuilder<ServerInfo> builder) {
    return subscribedBuilder<ServerInfo>("/server_info", builder: builder);
  }

  ValueListenableBuilder<Bandwidth> bandwidth(
      ValueWidgetBuilder<Bandwidth> builder) {
    return subscribedBuilder<Bandwidth>("/bandwidth", builder: builder);
  }
}
