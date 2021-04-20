import 'package:flutter/services.dart';

class LanternNavigator {
  static MethodChannel methodChannel =
      const MethodChannel('navigator_method_channel');

  static void startScreen(String screenName) {
    methodChannel.invokeMethod(
        'startScreen', <String, dynamic>{'screenName': screenName});
  }

  static const String SCREEN_PLANS = 'SCREEN_PLANS';
}
