import 'dart:async';

import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:lantern/config/catcher_setup.dart';

import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Catcher(
      rootWidget: LanternApp(),
      debugConfig: catcherOptions,
      releaseConfig: catcherOptions);
  // runApp(LanternApp());
}
