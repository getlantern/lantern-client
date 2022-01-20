import 'package:flutter_test/flutter_test.dart';

Future<void> awaitFor(
  WidgetTester tester, {
  Duration duration = const Duration(seconds: 1),
}) async =>
    await tester.pump(duration);
