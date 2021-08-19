import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lantern/config/catcher_setup.dart';

import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupCatcherAndRun(LanternApp());
}
