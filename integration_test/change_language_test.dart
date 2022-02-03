import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'change_language_test';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

  // TODO: WIP
  group(testName, () {
    test(
      'Set language to French',
      () async {
        await driver.tapText(
          'Account',
          waitText: 'Account',
        );
        await driver.tapText(
          'Settings',
          waitText: 'Settings',
        );
        await driver.tapText(
          'Language',
          waitText: 'Language',
        );
        await driver.scrollTextUntilVisible('Français');
        await driver.tapText('Français');
        await driver.waitForSeconds(2);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
