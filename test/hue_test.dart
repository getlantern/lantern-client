import 'package:lantern/features/messaging/messaging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sha1Hue', () {
    test(
        'sha1Hue for specific string should return specific expected value that matches the test in messaging-android',
        () {
      // this matches the result here - https://github.com/getlantern/messaging-android/pull/40/files#diff-ba1bee5641ab2a19b20bcae8c8adedbfe1252ece23ec66e0b52b067b179e6fb8R1895
      expect(
        sha1Hue('rtfr4noprty198jhdssetbegxq4y5fsh2rfrn96x7nx7tj8tutqy'),
        173.0,
      );
    });
  });
}
