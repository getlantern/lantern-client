import 'dart:ui' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/app.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:window_manager/window_manager.dart';
import 'package:lantern/core/purchase/app_purchase.dart';
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
  try {
    // To load the .env file contents into dotenv.
    await dotenv.load(fileName: "app.env");
  } catch (error) {
    appLogger.e("Error loading .env file: $error");
  }

  if (isDesktop()) {
    loadLibrary();
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: ui.Size(360, 712),
      minimumSize: ui.Size(315, 584),
      maximumSize: ui.Size(1000, 1000),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      windowButtonVisibility: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    await _initGoogleMobileAds();
  }

  // Inject all the services
  init();
  sl<AppPurchase>().init();
  // await _initGoogleMobileAds();
  await Localization.ensureInitialized();
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

  // setupCatcherAndRun(const LanternApp());
  setupCatcherAndRun(Container(
    color: Colors.amber,
  ),);
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
  await MobileAds.instance.setAppMuted(true);
}
