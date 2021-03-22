import 'package:flutter/services.dart';

import 'model/protobuf_message_codec.dart';

class LanternNavigator {
  static MethodChannel methodChannel = MethodChannel(
      "navigator_method_channel", StandardMethodCodec(ProtobufMessageCodec()));

  static startActivity(String activityName) {
    methodChannel.invokeMethod(
        'startActivity', <String, dynamic>{"activityName": activityName});
  }

  static const String ACTIVITY_PLANS = "ACTIVITY_PLANS";
}
