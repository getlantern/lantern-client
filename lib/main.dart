import 'package:flutter_driver/driver_extension.dart';
import 'package:lantern/catcher_setup.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/flutter_driver_extensions/add_dummy_contacts_command_extension.dart';
import 'package:lantern/flutter_driver_extensions/navigate_command_extension.dart';
import 'package:lantern/flutter_driver_extensions/send_dummy_files_command_extension.dart';

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
      commands: <CommandExtension>[
        NavigateCommandExtension(),
        AddDummyContactsCommandExtension(),
        SendDummyFilesCommandExtension(),
      ],
    );
  }
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupCatcherAndRun(LanternApp());
}
