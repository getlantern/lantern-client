import 'dart:ui' as ui;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/app.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/core/service/app_purchase.dart';
import 'package:lantern/features/replica/ui/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

WebViewEnvironment? webViewEnvironment;

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
    await initializeWebViewEnvironment();
    await windowManager.ensureInitialized();
    await windowManager.setSize(const ui.Size(360, 712));
    LanternFFI.startDesktopService();
    await WebsocketSubscriber().connect();
  } else {
    await _initGoogleMobileAds();
    // Inject all the services
    init();
    sl<AppPurchase>().init();
    // Due to replica we are using lot of cache
    // clear if goes to above limit
    CustomCacheManager().clearCacheIfExceeded();
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
    options.environment = kReleaseMode ? "production" : "development";
    options.dsn = kReleaseMode ? AppSecret.dnsConfig() : "";
    options.enableNativeCrashHandling = true;
    options.attachStacktrace = true;
  }, appRunner: () => runApp(const LanternApp()));
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
  // await MobileAds.instance.setAppMuted(true);
}

Future<void> initializeWebViewEnvironment() async {
  if (!isDesktop()) return;
  final directory = await getApplicationDocumentsDirectory();
  final localAppDataPath = directory.path;

  // Ensure WebView2 runtime is available
  final availableVersion = await WebViewEnvironment.getAvailableVersion();
  assert(availableVersion != null,
      'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

  webViewEnvironment = await WebViewEnvironment.create(
    settings: WebViewEnvironmentSettings(
      userDataFolder: '$localAppDataPath\\Lantern\\WebView2',
    ),
  );
}
