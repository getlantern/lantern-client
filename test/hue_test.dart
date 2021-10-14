import 'package:lantern/account/account.dart';
import 'package:test/test.dart';
import 'package:lantern/common/ui/humanize.dart';

void main() {
  group('sha1Hue', () {
    test(
        'sha1Hue for specific string should return specific expected value that matches the test in messaging-android',
        () {
      expect(sha1Hue('rtfr4noprty198jhdssetbegxq4y5fsh2rfrn96x7nx7tj8tutqy'),
          173.0);
    });
  });
}
