import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/app.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/common_desktop.dart';
import 'package:lantern/features/replica/ui/utils.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// IOS issue
// https://github.com/flutter/flutter/issues/133465
Future<void> main({bool testMode = false}) async {
// CI will be true only when running appium test
  WidgetsFlutterBinding.ensureInitialized();
  await Localization.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    // To load the .env file contents into dotenv.
    await dotenv.load(fileName: "app.env");
  } catch (error) {
    appLogger.e("Error loading .env file: $error");
  }

  // Inject all the services
  await initServices();
  await _desktopService();
  await _initGoogleMobileAds();
  // Due to replica we are using lot of cache
  // clear if goes to above limit
  CustomCacheManager().clearCacheIfExceeded();

  if (testMode) {
    runApp(const LanternApp());
  } else {
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
  if (!isDesktop()) return;
  // start backend services before setting up window
  LanternFFI.startDesktopService();
  await WebsocketSubscriber().connect();
}

Future<void> _initGoogleMobileAds() async {
  if (isDesktop()) return;
  await MobileAds.instance.initialize();
  // await MobileAds.instance.setAppMuted(true);
}
