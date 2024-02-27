import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lantern/app.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/ffi.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:ui' as ui;
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
    print(error);
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

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupCatcherAndRun(LanternApp());
}

Future<void> _initGoogleMobileAds() async {
  await MobileAds.instance.initialize();
  await MobileAds.instance.setAppMuted(true);
}
