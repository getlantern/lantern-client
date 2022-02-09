import 'package:flutter_driver/driver_extension.dart';
import 'package:lantern/catcher_setup.dart';
import 'package:lantern/common/common.dart';

import 'app.dart';

Future<void> main() async {
  if (const String.fromEnvironment(
        'driver',
        defaultValue: 'false',
      ).toLowerCase() ==
      'true') {
    // https://github.com/flutter/flutter/pull/12909/commits/e6ce75425fd7284a5568188429d5e6533ae6388e and https://github.com/flutter/flutter/issues/15415
    enableFlutterDriverExtension(
      handler: (message) async => (message ?? '').i18n,
    );
  }
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupCatcherAndRun(LanternApp());
}
