import 'package:flutter_driver/driver_extension.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/app.dart';
import 'package:lantern/common/common.dart';
import 'catcher_setup.dart';

// IOS issue
// https://github.com/flutter/flutter/issues/133465
Future<void> main() async {
  // CI will be true only when running appium test
  const String flavor = String.fromEnvironment('app.flavor');
  print("Running Flavor $flavor");
  if (flavor == 'appiumTest') {
    print("Flutter extension enabled $flavor");
    enableFlutterDriverExtension();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await _initGoogleMobileAds();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //Todo if catcher is not picking up error and exception then we should switch to sentryFlutter
  // SentryFlutter.init((options) {
  //   options.debug = true;
  //   options.anrEnabled = true;
  //   options.autoInitializeNativeSdk = true;
  //   options.attachScreenshot = true;
  //   options.dsn = Platform.isAndroid
  //       ? 'https://4753d78f885f4b79a497435907ce4210@o75725.ingest.sentry.io/5850353'
  //       : 'https://c14296fdf5a6be272e1ecbdb7cb23f76@o75725.ingest.sentry.io/4506081382694912';
  // }, appRunner: () => setupCatcherAndRun(LanternApp()));

  setupCatcherAndRun(LanternApp());
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
  await MobileAds.instance.setAppMuted(true);
  // await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ['b7574600c8a2fa26a110699cc2ae83d3']));
  // MobileAds.instance.openAdInspector((p0) {
  //   print('ad error $p0');
  // });
}
