import 'integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'introductions';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await FlutterDriver.connect(timeout: const Duration(seconds: 15));
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

// * Test requirements
// * Needs to have received a _single_ introduction from another user
  group(testName, () {
    test(
      'Accept an introduction',
      () async {
        await driver.tapText(await driver.requestData('introductions'));

        await driver
            .tapText((await driver.requestData('reject')).toUpperCase());

        await driver
            .tapText((await driver.requestData('cancel')).toUpperCase());

        await driver
            .tapText((await driver.requestData('accept')).toUpperCase());
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
