import 'package:lantern/model/model.dart';

class VpnModel extends Model {
  VpnModel(
      {String methodChannelName = 'vpn_method_channel',
      String eventChannelName = 'vpn_event_channel'})
      : super(methodChannelName, eventChannelName) {
    // do something here
  }
}
