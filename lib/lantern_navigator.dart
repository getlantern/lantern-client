import 'package:flutter/services.dart';

class LanternNavigator {
  static MethodChannel methodChannel =
      MethodChannel("navigator_method_channel");

  static startActivity(String activityName) {
    methodChannel.invokeMethod(
        'startActivity', <String, dynamic>{"activityName": activityName});
  }

  static const String ACTIVITY_PLANS = "ACTIVITY_PLANS";
}
