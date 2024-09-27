import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:lantern/core/utils/common.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Localization.ensureInitialized();
  });

  group('Tests for humanizeSeconds()', () {
    test('Longform seconds - should return 30 seconds', () {
      final result = 30.humanizeSeconds(longForm: true);
      expect(result, '30 seconds');
    });
    test('Shortform seconds - should return 30s', () {
      final result = 30.humanizeSeconds();
      expect(result, '30s');
    });

    test('Longform minutes - should return 30 minutes', () {
      final result = 1800.humanizeSeconds(longForm: true);
      expect(result, '30 minutes');
    });
    test('Shortform minutes - should return 30m', () {
      final result = 1800.humanizeSeconds();
      expect(result, '30m');
    });

    test('Longform hours - should return 22 hours', () {
      final result = 80000.humanizeSeconds(longForm: true);
      expect(result, '22 hours');
    });
    test('Shortform hours - should return 22h', () {
      final result = 80000.humanizeSeconds();
      expect(result, '22h');
    });

    test('Longform days - should return 6 days', () {
      final result = 600000.humanizeSeconds(longForm: true);
      expect(result, '6 days');
    });
    test('Shortform days - should return 6d', () {
      final result = 600000.humanizeSeconds();
      expect(result, '6d');
    });

    test('Longform weeks - should return 4 weeks', () {
      final result = 2600000.humanizeSeconds(longForm: true);
      expect(result, '4 weeks');
    });
    test('Shortform weeks - should return 4w', () {
      final result = 2600000.humanizeSeconds();
      expect(result, '4w');
    });

    test('Longform months or years  - should return 50 weeks', () {
      final result = 30240000.humanizeSeconds(longForm: true);
      expect(result, '50 weeks');
    });
    test('Shortform months or years - should return 350d', () {
      final result = 30240000.humanizeSeconds();
      expect(result, '350d');
    });
  });

  group('Tests for humanizePastFuture() - past', () {
    test('Event was 20 seconds ago', () {
      final now = DateTime.now();
      final dateTime = now.subtract(const Duration(seconds: 20));
      final expected = 'just now';

      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('result: $result');
    });

    test('Event was 6 hours ago', () {
      final now = DateTime.now();
      final dateTime = now.subtract(const Duration(hours: 6));
      final expected = DateFormat('jm').format(dateTime);

      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('result: $result');
    });

    test('Event was yesterday', () {
      final now = DateTime.now();
      final dateTime = now.subtract(const Duration(days: 1));
      final expected = 'yesterday';

      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('result: $result');
    });

    test('Event was 3 days ago', () {
      final now = DateTime.now();
      final dateTime = now.subtract(const Duration(days: 3));
      final expected = DateFormat('EEEE').format(dateTime);

      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('result: $result');
    });
    test('Event was far in the past', () {
      final now = DateTime.now();
      final dateTime = DateTime(2021, 9, 8, 16, 30);
      final expected = '9/8/2021';
      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('actual: $result');
    });
  });

  group('Tests for humanizePastFuture() - future', () {
    test('Event will be within the next minue', () {
      final now = DateTime.now();
      final dateTime = now.add(const Duration(seconds: 30));
      final expected = 'within one minute';

      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('actual: $result');
    });
    test('Event will be by EOD today', () {
      final now = DateTime.now();
      final dateTime = now.add(const Duration(minutes: 45));
      final expected = 'at ${DateFormat('jm').format(dateTime)}';

      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('actual: $result');
    });
    test('Event will be tomorrow', () {
      final now = DateTime.now();
      final dateTime = now.add(const Duration(days: 1));
      final expected = 'tomorrow';

      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('actual: $result');
    });
    test('Event will be 3 days from now', () {
      final now = DateTime.now();
      final dateTime = now.add(const Duration(days: 3));
      final expected =
          'on ${DateFormat('EEEE').format(dateTime)}, at ${DateFormat('jm').format(dateTime)}';

      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('actual: $result');
    });
    test('Event will be far in the future', () {
      final now = DateTime.now();
      final dateTime = DateTime(2022, 9, 8, 16, 30);
      final expected = 'on 9/8/2022, at 4:30 PM';

      var result = humanizePastFuture(now, dateTime);
      print('expected: $expected');
      expect(result, expected);
      print('actual: $result');
    });
  });
}
