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
  static var dirPath = '';

  Future<void> initScreenshotsDirectory(testName) async {
    dirPath = 'screenshots/$testName';
    final directory = Directory(dirPath);
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create();
  }

  Future<void> saveScreenshot(String name, {bool? skipScreenshot}) async {
    if (skipScreenshot == true) return;

    final png = await screenshot();
    final file = File(
      join(
        dirPath,
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
    bool? skipScreenshot,
  }) async {
    try {
      await tapFinder(
        find.text(tapText),
        waitText: waitText,
        skipScreenshot: skipScreenshot,
      );
    } catch (_) {
      // try it with non-breaking spaces like those added by CText
      await tapFinder(
        find.text(addNonBreakingSpaces(tapText)),
        waitText: waitText,
      );
    }
  }

  Future<void> tapFAB({
    String? waitText,
    bool? skipScreenshot,
  }) async {
    await tapType(
      'FloatingActionButton',
      waitText: waitText,
      skipScreenshot: skipScreenshot,
    );
  }

  Future<void> tapType(
    String type, {
    String? waitText,
    bool? skipScreenshot,
  }) async {
    await tapFinder(
      find.byType(type),
      waitText: waitText,
      skipScreenshot: skipScreenshot,
    );
  }

  Future<void> tapKey(
    String key, {
    String? waitText,
    bool? skipScreenshot,
  }) async {
    await tapFinder(
      find.byValueKey(key),
      waitText: waitText,
      skipScreenshot: skipScreenshot,
    );
  }

  Future<void> tapFinder(
    SerializableFinder finder, {
    String? waitText,
    bool? skipScreenshot,
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
      await saveScreenshot(
        'tap $finder wait for $waitText',
        skipScreenshot: skipScreenshot,
      );
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

  Future<void> waitForTwoSeconds() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
