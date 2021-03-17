import 'package:lantern/model/model.dart';

class VpnModel extends Model {
  VpnModel() : super("vpn") {}

  Future<void> switchVPN<T>(String path, bool on) async {
    methodChannel.invokeMethod('switchVPN', <String, dynamic>{
      "on": on,
    });
  }
}
