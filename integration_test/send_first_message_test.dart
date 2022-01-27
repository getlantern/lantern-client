import 'package:lantern/common/add_nonbreaking_spaces.dart';

import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'send_first_message';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(testName, () {
    test(
      'Send first message',
      () async {
        await driver.resetFlagsAndEnrollAgain(skipScreenshot: true);

        print('accessing conversation');
        await driver.tapType(
          'ListItemFactory',
        );

        print('typing text');
        await driver.typeAndSend(
          'Hi how are you?',
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
