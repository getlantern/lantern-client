import 'package:flutter_driver/driver_extension.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/app.dart';
import 'package:lantern/common/common.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'catcher_setup.dart';

Future<void> main() async {
  // CI will be true only when running appium test
  final start = DateTime.now();
  const String flavor = String.fromEnvironment('app.flavor');
  print("Running Flavor $flavor");
  if (flavor == 'appiumTest') {
    print("Flutter extension enabled $flavor");
    enableFlutterDriverExtension();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  compute((message) => Localization.ensureInitialized, null);
  if (Platform.isAndroid) {
    await _initGoogleMobileAds();
  }
  //Todo if catcher is not picking up error and exception then we should switch to sentryFlutter
  SentryFlutter.init((options) {
    options.autoInitializeNativeSdk = false;
    options.dsn = kReleaseMode
        ? Platform.isAndroid
            ? 'https://4753d78f885f4b79a497435907ce4210@o75725.ingest.sentry.io/5850353'
            : 'https://c14296fdf5a6be272e1ecbdb7cb23f76@o75725.ingest.sentry.io/4506081382694912'
        : "";
  }, appRunner: () => setupCatcherAndRun(LanternApp()));
  final end = DateTime.now();
  print(
      "[Performance Logs] main.dart main time taken ${end.difference(start)}");

  // setupCatcherAndRun(LanternApp());
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
  await MobileAds.instance.setAppMuted(true);
  // await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ['D79728264130CE0918737B5A2178D362']));
  // MobileAds.instance.openAdInspector((p0) {
  //   print('ad error $p0');
  // });
}
