import 'package:flutter/services.dart';

class LanternNavigator {
  static MethodChannel methodChannel =
      const MethodChannel('navigator_method_channel');

  static void startScreen(String screenName) {
    methodChannel.invokeMethod(
      'startScreen',
      <String, dynamic>{'screenName': screenName},
    );
  }

  static const String SCREEN_PLANS = 'SCREEN_PLANS';
  static const String SCREEN_INVITE_FRIEND = 'SCREEN_INVITE_FRIEND';
  static const String SCREEN_DESKTOP_VERSION = 'SCREEN_DESKTOP_VERSION';
  static const String SCREEN_LINK_PIN = 'SCREEN_LINK_PIN';
  static const String SCREEN_SCREEN_REPORT_ISSUE = 'SCREEN_SCREEN_REPORT_ISSUE';
  static const String SCREEN_UPGRADE_TO_LANTERN_PRO =
      'SCREEN_UPGRADE_TO_LANTERN_PRO';
}
