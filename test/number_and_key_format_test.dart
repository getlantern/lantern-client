import 'package:lantern/features/messaging/messaging.dart';
import 'package:test/test.dart';

void main() {
  group('ChatNumber', () {
    test('standard short chat number should format correctly', () {
      expect('123456789012'.formattedChatNumber, '123 456 789 012');
    });
    test('incomplete short chat number should format correctly', () {
      expect('12345678901'.formattedChatNumber, '123 456 789 01');
    });
    test('extended short chat number should format correctly', () {
      expect('5512345678901255'.formattedChatNumber, '55 123 456 789 012 55');
    });
    test('short chat number with whitespace should format correctly', () {
      expect('  12345 67890 12  \t'.formattedChatNumber, '123 456 789 012');
    });
  });

  group('RecoveryKey', () {
    test('standard recovery key', () {
      expect(
        'abcd1234efgh7890ij'.formattedRecoveryKey,
        'abcd 1234 efgh 7890 ij',
      );
    });
    test('malformed recovery key', () {
      expect('34.435345'.formattedRecoveryKey, '34.435345');
    });
  });
}
