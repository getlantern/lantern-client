import 'package:lantern/messaging/messaging.dart';
import 'package:test/test.dart';

void main() {
  group('ChatNumberFormat', () {
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
}
