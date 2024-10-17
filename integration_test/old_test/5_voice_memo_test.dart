import '../integration_test_common.dart';

Future<void> main() async {
  await runTest(
    (driver) async {
      await driver.openTab('chats', homeFirst: true);

      await driver.tapFAB();

      // Looking for "Me" works for most languages.
      // However in some cases (Chinese), "Me" is a single character, and so is the alphabetic marker we use to separate contacts, which confuses the test driver.
      // In that case, we can just find the first element of the 'grouped_contact_list' ListBody.
      try {
        await driver.tapText('me');
      } catch (_) {
        print(
          'there was an issue tapping on Me conversation, will find another contact',
        );
        await driver.tapFirstItemInList('grouped_contact_list');
      }

      final recorderButtonFinder = find.byValueKey('recorder_button');

      print('tapping on start record button');
      await driver.longPress(target: recorderButtonFinder);

      print('tapping on stop record button');
      await driver.longPress(target: recorderButtonFinder);

      print('tapping on send');
      await driver.tapKey('send_message');
    },
  );
}
