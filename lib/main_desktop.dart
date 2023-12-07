import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lantern/app.dart';
import 'package:lantern/app_desktop.dart';
import 'package:lantern/ffi.dart';
import 'package:system_tray/system_tray.dart';

Future<void> main() async {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  WidgetsFlutterBinding.ensureInitialized();
  loadLibrary();
  runApp(DesktopApp());
}
