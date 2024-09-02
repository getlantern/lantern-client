import 'dart:ui' as ui;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/app.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/core/purchase/app_purchase.dart';
import 'package:lantern/replica/ui/utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

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
    LanternFFI.startDesktopService();
    await WebsocketSubscriber().connect();
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
    // Due to replica we are using lot of cache
    // clear if goes to above limit
    CustomCacheManager().clearCacheIfExceeded();
    if (Platform.isIOS) {
      // Inject all the services
      init();
      sl<AppPurchase>().init();
    }
  }

  await Localization.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SentryFlutter.init((options) {
    // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
    // We recommend adjusting this value in production.
    options.tracesSampleRate = 1.0;
    // The sampling rate for profiling is relative to tracesSampleRate
    // Setting to 1.0 will profile 100% of sampled transactions:
    options.profilesSampleRate = 1.0;
    options.dsn = kReleaseMode ? dnsConfig() : "";
    options.enableNativeCrashHandling = true;
  }, appRunner: () => runApp(const LanternApp()));

  // setupCatcherAndRun(const LanternApp());
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
  await MobileAds.instance.setAppMuted(true);
}
