import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:lantern/common/add_nonbreaking_spaces.dart';
import 'package:path/path.dart';

export 'package:flutter_driver/flutter_driver.dart';
export 'package:test/test.dart';

extension DriverExtension on FlutterDriver {
  static var screenshotSequence = 0;
  static const defaultWaitTimeout = Duration(seconds: 5);
  static const defaultTapTimeout = Duration(seconds: 1);

  Future<void> initScreenshotsDirectory() async {
    final directory = Directory('screenshots');
    await directory.delete(recursive: true);
    await directory.create();
  }

  Future<void> saveScreenshot(String name) async {
    final png = await screenshot();
    final file = File(
      join(
        'screenshots',
        '${++screenshotSequence}_$name.png',
      ),
    );
    await file.writeAsBytes(png);
  }

  Future<void> waitForText(String waitText) async {
    try {
      await doWaitForText(waitText);
    } finally {
      await saveScreenshot('wait for $waitText');
    }
  }

  Future<void> doWaitForText(String waitText) async {
    try {
      await waitFor(
        find.text(waitText),
        timeout: defaultWaitTimeout,
      );
    } catch (_) {
      // try it with non-breaking spaces like those added by CText
      await waitFor(
        find.text(addNonBreakingSpaces(waitText)),
        timeout: defaultWaitTimeout,
      );
    }
  }

  Future<void> tapText(
    String tapText, {
    String? waitText,
  }) async {
    try {
      await tapFinder(
        find.text(tapText),
        waitText: waitText,
      );
    } catch (_) {
      // try it with non-breaking spaces like those added by CText
      await tapFinder(
        find.text(addNonBreakingSpaces(tapText)),
        waitText: waitText,
      );
    }
  }

  Future<void> tapFAB({String? waitText}) async {
    await tapType('FloatingActionButton', waitText: waitText);
  }

  Future<void> tapType(String type, {String? waitText}) async {
    await tapFinder(find.byType(type), waitText: waitText);
  }

  Future<void> tapKey(String key, {String? waitText}) async {
    await tapFinder(find.byValueKey(key), waitText: waitText);
  }

  Future<void> tapFinder(
    SerializableFinder finder, {
    String? waitText,
  }) async {
    try {
      await tap(
        finder,
        timeout: defaultTapTimeout,
      );
      if (waitText != null) {
        await doWaitForText(waitText);
      }
    } finally {
      await saveScreenshot('tap $finder wait for $waitText');
    }
  }

  Future<void> scrollTextUntilVisible(
    String text,
  ) async {
    try {
      final scrollable = find.byType('ListView');
      await waitFor(
        scrollable,
        timeout: defaultWaitTimeout,
      );
      await scrollUntilVisible(
        scrollable,
        find.text(text),
        dyScroll: -1000,
        timeout: const Duration(
          seconds: 600,
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
