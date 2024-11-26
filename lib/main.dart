import 'dart:ui' as ui;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/app.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/features/replica/ui/utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

// IOS issue
// https://github.com/flutter/flutter/issues/133465
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     // To load the .env file contents into dotenv.
//     await dotenv.load(fileName: "app.env");
//   } catch (error) {
//     appLogger.e("Error loading .env file: $error");
//   }
//
//   _desktopService();
//   // Inject all the services
//   await initServices();
//   await _initGoogleMobileAds();
//   // Due to replica we are using lot of cache
//   // clear if goes to above limit
//   CustomCacheManager().clearCacheIfExceeded();
//   // if (isDesktop()) {
//   //   // if (Platform.isWindows) await initializeWebViewEnvironment();
//   //   // await windowManager.ensureInitialized();
//   //   // await windowManager.setSize(const ui.Size(360, 712));
//   //   // LanternFFI.startDesktopService();
//   //   // await WebsocketSubscriber().connect();
//   // } else {
//   //
//   //
//   //
//   //
//   // }
//
//   SentryFlutter.init((options) {
//     // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
//     // We recommend adjusting this value in production.
//     options.tracesSampleRate = 1.0;
//     // The sampling rate for profiling is relative to tracesSampleRate
//     // Setting to 1.0 will profile 100% of sampled transactions:
//     options.profilesSampleRate = 1.0;
//     options.environment = kReleaseMode ? "production" : "development";
//     options.dsn = kReleaseMode ? AppSecret.dnsConfig() : "";
//     options.enableNativeCrashHandling = true;
//     options.attachStacktrace = true;
//   }, appRunner: () => runApp(const LanternApp()));
// }

Future<void> main({bool testMode = false}) async {
// CI will be true only when running appium test
  WidgetsFlutterBinding.ensureInitialized();
  Localization.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  appLogger.d('LanternApp main');
  try {
    // To load the .env file contents into dotenv.
    await dotenv.load(fileName: "app.env");
  } catch (error) {
    appLogger.e("Error loading .env file: $error");
  }

  await Future.microtask(_desktopService);
  appLogger.d('LanternApp main after desktop service');
  // Inject all the services
  await initServices();
  appLogger.d('LanternApp main after init services');
  await _initGoogleMobileAds();
  // Due to replica we are using lot of cache
  // clear if goes to above limit
  if (testMode) {
    appLogger.d('Running in test mode');
    runApp(const LanternApp());
  } else {
    appLogger.d('Running in normal mode');
    await CustomCacheManager().clearCacheIfExceeded();
    SentryFlutter.init((options) {
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      options.environment = kReleaseMode ? "production" : "development";
      options.dsn = kReleaseMode ? AppSecret.dnsConfig() : "";
      options.enableNativeCrashHandling = true;
      options.attachStacktrace = true;
    }, appRunner: () => runApp(const LanternApp()));
  }
}

Future<void> _desktopService() async {
  if (isDesktop()) {
    if (Platform.isWindows) await initializeWebViewEnvironment();
    await windowManager.ensureInitialized();
    await windowManager.setSize(const ui.Size(360, 712));
    LanternFFI.startDesktopService();
    await WebsocketSubscriber().connect();
  }
}

Future<void> _initGoogleMobileAds() async {
  if (isDesktop()) return;
  await MobileAds.instance.initialize();
  // await MobileAds.instance.setAppMuted(true);
}
