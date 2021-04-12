import 'package:flutter/services.dart';

class LanternNavigator {
  static MethodChannel methodChannel =
      MethodChannel("navigator_method_channel");

  static startScreen(String screenName) {
    methodChannel.invokeMethod(
        'startScreen', <String, dynamic>{"screenName": screenName});
  }

  static const String SCREEN_PLANS = "SCREEN_PLANS";
  static const String SCREEN_INVITE_FRIEND = "SCREEN_INVITE_FRIEND";
  static const String SCREEN_DESKTOP_VERSION = "SCREEN_DESKTOP_VERSION";
  static const String SCREEN_FREE_YINBI = "SCREEN_FREE_YINBI";
  static const String SCREEN_YINBI_REDEMPTION = "SCREEN_YINBI_REDEMPTION";
  static const String SCREEN_AUTHORIZE_DEVICE_FOR_PRO = "SCREEN_AUTHORIZE_DEVICE_FOR_PRO";
  static const String SCREEN_CHANGE_LANGUAGE = "SCREEN_CHANGE_LANGUAGE";
  static const String SCREEN_SCREEN_REPORT_ISSUE = "SCREEN_SCREEN_REPORT_ISSUE";
  static const String SCREEN_ACCOUNT_MANAGEMENT = "SCREEN_ACCOUNT_MANAGEMENT";
  static const String SCREEN_ADD_DEVICE = "SCREEN_ADD_DEVICE";
  static const String SCREEN_UPGRADE_TO_LANTERN_PRO = "SCREEN_UPGRADE_TO_LANTERN_PRO";
}
