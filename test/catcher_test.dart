import 'package:catcher/catcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/config/catcher_setup.dart';
import 'package:lantern/ui/app.dart';

void main() {
  Catcher catcher;
  setUp(() {
    catcher = setupCatcherAndRun(LanternApp());
  });

  testWidgets('Test Catcher', (WidgetTester tester) async {
    print('Catcher is just a wrapper that notify any 3rd party error handler');
    print(
        'Catcher should throw a custom exception and the logger should be displayed on the console');
    expect(() => Catcher.sendTestException(), throwsA(isA<FormatException>()));
  });
}
