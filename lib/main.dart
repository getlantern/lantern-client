import 'package:flutter_driver/driver_extension.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/catcher_setup.dart';
import 'package:lantern/common/common.dart';

import 'app.dart';

// https://github.com/googleads/googleads-mobile-flutter/blob/main/samples/admob/mediation_example/android/app/src/main/java/com/example/mediationexample/MyMediationMethodCallHandler.java
Future<void> main() async {
  // CI will be true only when running appium test
  var CI = const String.fromEnvironment('CI', defaultValue: 'false');
  print('CI is running $CI');
  if (CI == 'true') {
    enableFlutterDriverExtension();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await _initGoogleMobileAds();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupCatcherAndRun(LanternApp());
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
  await MobileAds.instance.setAppMuted(true);
  // await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ['D79728264130CE0918737B5A2178D362']));
}
