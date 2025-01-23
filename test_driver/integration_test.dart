import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  /// Looks like flutter has a bug where it doesn't properly handle
  /// the permissions request.
  /// https://github.com/flutter/flutter/issues/12561
  /// we need to execute a custom command with android adb in order to grant
  /// permissions to the app.

  // final envVars = Platform.environment;
  // final adbPath = '${envVars['ANDROID_HOME']}/platform-tools/adb';
  // await Process.run(adbPath, [
  //   'shell',
  //   'pm',
  //   'grant',
  //   'org.getlantern.lantern',
  //   'android.permission.READ_EXTERNAL_STORAGE'
  // ]);
  // await Process.run(adbPath, [
  //   'shell',
  //   'pm',
  //   'grant',
  //   'org.getlantern.lantern',
  //   'android.permission.RECORD_AUDIO'
  // ]);
  await integrationDriver();
}
