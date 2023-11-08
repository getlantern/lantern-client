import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:lantern/flutter_go.dart';
import 'package:flutter/services.dart';
import 'package:lantern/app.dart';
import 'package:lantern/app_desktop.dart';
import 'package:lantern/ffi.dart';

Future<void> main() async {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  WidgetsFlutterBinding.ensureInitialized();
  testffi();
  runApp(DesktopApp());
}