import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  /// Looks like flutter has a bug where it doesn't properly handle
  /// the permissions request.
  /// https://github.com/flutter/flutter/issues/12561
  /// we need to execute a custom command with android adb in order to grant
  /// permissions to the app.

  /// Please change the following line to your own adb path.
  final adbPath = '/Users/crdzbird/Library/Android/sdk/platform-tools/adb';
  await Process.run(adbPath, [
    'shell',
    'pm',
    'grant',
    'org.getlantern.lantern.LanternApp',
    'android.permission.READ_EXTERNAL_STORAGE'
  ]);
  await Process.run(adbPath, [
    'shell',
    'pm',
    'grant',
    'org.getlantern.lantern.LanternApp',
    'android.permission.RECORD_AUDIO'
  ]);
  await integrationDriver();
}
