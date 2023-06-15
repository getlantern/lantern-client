import 'package:flutter_driver/driver_extension.dart';
import 'package:lantern/catcher_setup.dart';
import 'package:lantern/common/common.dart';

import 'app.dart';

Future<void> main() async {
  // CI will be true only when running appium test
  var CI = const String.fromEnvironment('CI', defaultValue: 'false');
  if (CI == 'true') {
    enableFlutterDriverExtension();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupCatcherAndRun(LanternApp());
}
