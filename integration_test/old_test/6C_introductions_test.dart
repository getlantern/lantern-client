import '../integration_test_common.dart';

Future<void> main() async {
  late FlutterDriver driver;
  final testName = 'introductions';

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
    await driver.initScreenshotsDirectory(testName);
  });

  tearDownAll(() async {
    await driver.close();
  });

// * Test requirements
// * Needs to have received a _single_ introduction from another user
  // TODO (not immediate): we can set up a second test driver so that one sends an intro to the other
  group(testName, () {
    test(
      'Accept an introduction',
      () async {
        await driver.openTab('chats', homeFirst: true);
        await driver.tapText('introductions');
        await driver.tapText('reject', capitalize: true);
        await driver.tapText('cancel', capitalize: true);
        await driver.tapText('accept', capitalize: true);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
