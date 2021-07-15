import 'package:flutter/material.dart';
import 'package:lantern/config/catcher_setup.dart';

import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupCatcherAndRun(LanternApp());
}
