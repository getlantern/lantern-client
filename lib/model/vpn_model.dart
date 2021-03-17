import 'package:lantern/model/model.dart';

class VpnModel extends Model {
  VpnModel() : super("vpn");

  static const PATH_VPN_STATUS = "/vpn_status";
  static const PATH_SERVER_INFO = "/server_info";
  static const PATH_BANDWIDTH = "/bandwidth";

  Future<void> switchVPN<T>(bool on) async {
    methodChannel.invokeMethod('switchVPN', <String, dynamic>{
      "on": on,
    });
  }
}
