import 'package:lantern/common/common.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'app.dart';

Future<void> main() async {
  // CI will be true only when running appium test
  var CI = const String.fromEnvironment('CI', defaultValue: 'false');
  print('CI is running $CI');
  if (CI == 'true') {
    enableFlutterDriverExtension();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(LanternApp());
}
