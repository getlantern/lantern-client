import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/common/common.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Localization.loadTranslations();
  });

  group('humanizeSeconds() tests', () {
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
}
