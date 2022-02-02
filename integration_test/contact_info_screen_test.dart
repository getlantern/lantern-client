import 'integration_test_common.dart';
import 'integration_test_constants.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'contact_info_screen';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 30));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(testName, () {
    test(
      '1/3 Access a contact info screen via long tap',
      () async {
        await driver.screenshotChatsView();

        await driver.longPressFirstMessage();

        await driver.tapText(
          'View Contact Info',
          overwriteTimeout: defaultWaitTimeout,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
    test(
      '2/3 Access a contact info screen via top right menu',
      () async {
        await driver.goBack();

        await driver.tapFirstMessage();

        print('tap on top right menu bar');
        await driver.tapKey(
          'topbar_more_menu',
          overwriteTimeout: defaultWaitTimeout,
        );

        await driver.tapText(
          'View Contact Info',
          overwriteTimeout: defaultWaitTimeout,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
