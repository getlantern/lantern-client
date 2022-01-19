import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:lantern/catcher_setup.dart';
import 'package:lantern/common/common.dart';

import 'app.dart';

Future<void> main() async {
  if (!kReleaseMode) {
    enableFlutterDriverExtension();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupCatcherAndRun(LanternApp());
}
