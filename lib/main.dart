import 'package:flutter_driver/driver_extension.dart';
import 'package:lantern/catcher_setup.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/flutter_driver_extensions/add_dummy_contacts_command_extension.dart';
import 'package:lantern/flutter_driver_extensions/navigate_command_extension.dart';
import 'package:lantern/flutter_driver_extensions/reset_flags_command_extension.dart';
import 'package:lantern/flutter_driver_extensions/send_dummy_files_command_extension.dart';

import 'app.dart';

Future<void> main() async {
  enableFlutterDriverExtension();

  // if (const String.fromEnvironment(
  //       'driver',
  //       defaultValue: 'false',
  //     ).toLowerCase() ==
  //     'true') {
  //   // Pass data to Flutter Driver
  //   // Useful -> https://github.com/flutter/flutter/pull/12909/commits/e6ce75425fd7284a5568188429d5e6533ae6388e
  //   // as well as https://github.com/flutter/flutter/issues/15415
  //   enableFlutterDriverExtension(
  //     handler: (message) async => (message ?? '').i18n,
  //     // on command and finder extensions https://arturkorobeynyk.medium.com/using-custom-finders-and-custom-commands-with-flutter-driver-extension-advanced-level-44df0286922b
  //     commands: <CommandExtension>[
  //       NavigateCommandExtension(),
  //       AddDummyContactsCommandExtension(),
  //       SendDummyFilesCommandExtension(),
  //       ResetFlagsCommandExtension(),
  //     ],
  //   );
  // }
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupCatcherAndRun(LanternApp());
}
