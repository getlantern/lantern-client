import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:lantern/common/add_nonbreaking_spaces.dart';
import 'package:path/path.dart';

export 'package:flutter_driver/flutter_driver.dart';
export 'package:test/test.dart';

extension DriverExtension on FlutterDriver {
  static var screenshotSequence = 0;
  static const defaultWaitTimeout = Duration(seconds: 5);
  static const longWaitTimeout = Duration(seconds: 20);
  static const veryLongWaitTimeout = Duration(seconds: 30);
  static const defaultTapTimeout = Duration(seconds: 1);
  static var dirPath = '';

  Future<void> initScreenshotsDirectory(testName) async {
    dirPath = 'screenshots/$testName';
    final directory = Directory(dirPath);
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create();
  }

  Future<void> saveScreenshot(String name) async {
    final png = await screenshot();
    final file = File(
      join(
        dirPath,
        '${++screenshotSequence}_$name.png',
      ),
    );
    await file.writeAsBytes(png);
  }

  // Future<void> waitForText(String waitText) async {
  //   try {
  //     await doWaitForText(waitText);
  //   } finally {
  //     await saveScreenshot('wait for $waitText');
  //   }
  // }

  /// handles non-breaking text wrapping
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

  /// invokes find.text(tapText)
  /// optional waitText and skipScreenshot
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
        skipScreenshot: skipScreenshot,
      );
    }
  }

  /// taps on Floating Action Button in Chats
  /// optional waitText and skipScreenshot
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

  /// invokes find.byType(type)
  /// optional waitText and skipScreenshot
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

  /// invokes find.byValueKey(key)
  /// optional waitText and skipScreenshot
  Future<void> tapKey(
    String key, {
    String? waitText,
    bool? skipScreenshot,
  }) async {
    try {
      print('key $key');
      await tapFinder(
        find.byValueKey(key),
        waitText: waitText,
        skipScreenshot: skipScreenshot,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> fakeLongPressAtKey(String key) async {
    final finder = find.byValueKey(key);
    await scroll(
      finder,
      0,
      0,
      longWaitTimeout,
      timeout: veryLongWaitTimeout,
    );
    await saveScreenshot(
      'recording',
    );
  }

  /// receives a SerializableFinder finder and taps at the center of the widget located by it. It handles text wrapping in case the finder can't locate the target.
  /// It saves a screenshot of the viewport unless skipScreenshot = true
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
      if (skipScreenshot == true) return;
      await saveScreenshot(
        'tap $finder wait for $waitText',
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

  Future<void> waitForSeconds(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  /// Developer → RESET FLAGS → Chats → GET STARTED → NEXT
  Future<void> resetFlagsAndEnrollAgain({bool? skipScreenshot}) async {
    await tapText(
      'Developer',
      waitText: 'Developer Settings',
      skipScreenshot: true,
    );
    await scrollTextUntilVisible('RESET FLAGS');
    await tapText(
      'RESET FLAGS',
      skipScreenshot: true,
    );
    await tapText(
      'Chats',
      waitText: 'Welcome to Lantern Chat!',
      skipScreenshot: skipScreenshot,
    );
    await tapText(
      'GET STARTED',
      waitText: 'Chat Number',
      skipScreenshot: skipScreenshot,
    );
    await tapText(
      'NEXT',
      waitText: 'Chats',
      skipScreenshot: skipScreenshot,
    );
  }

  /// Locates message bar, types a message and sends it
  Future<void> typeAndSend(String messageContent) async {
    await tapType('TextFormField');
    await enterText(
      messageContent,
      timeout: const Duration(seconds: 1),
    );
    await tapKey('send_message');
    await waitForSeconds(1);
  }
}
