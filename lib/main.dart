import 'package:lantern/catcher_setup.dart';
import 'package:lantern/common/common.dart';

import 'app.dart';

Future<void> main() async {
  //this works only in debug and profile mode
  // enableFlutterDriverExtension();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(LanternApp());
}
