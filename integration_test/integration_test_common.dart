import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:lantern/common/add_nonbreaking_spaces.dart';
import 'package:path/path.dart';

import 'integration_test_constants.dart';

export 'package:flutter_driver/flutter_driver.dart';
export 'package:test/test.dart';

extension DriverExtension on FlutterDriver {
  static var screenshotSequence = 0;
  static var dirPath = '';

  Future<void> initScreenshotsDirectory(testName) async {
    await clearTimeline();
    dirPath = 'screenshots/$testName';
    final directory = Directory(dirPath);
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create();
  }

  Future<void> saveScreenshot(String name) async {
    try {
      final png = await screenshot();
      final screenshotName = join(
        dirPath,
        '${++screenshotSequence}_$name.png',
      );
      final file = File(screenshotName);
      await file.writeAsBytes(png);
    } catch (e) {
      print(e);
    }
  }

  /// finds and clicks the top left back button
  Future<void> goBack() async {
    final backButton = const PageBack();
    print('going back');
    try {
      await tap(backButton, timeout: defaultTapTimeout);
    } catch (e) {
      print('Hit home, will wait');
    }
  }

  // Future<void> waitForText(String waitText) async {
  //   try {
  //     await doWaitForText(waitText);
  //   } finally {
  //     await saveScreenshot('wait for $waitText');
  //   }
  // }

  /// Handles non-breaking text wrapping
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

  /// Taps on widget after it localizes it via find.text()
  Future<void> tapText(
    String tapText, {
    String? waitText,
    bool? skipScreenshot,
    Duration? overwriteTimeout,
  }) async {
    print('tapping on text: $tapText');
    try {
      await tapFinder(
        find.text(tapText),
        waitText: waitText,
        skipScreenshot: skipScreenshot,
        overwriteTimeout: overwriteTimeout,
      );
    } catch (_) {
      // try it with non-breaking spaces like those added by CText
      await tapFinder(
        find.text(addNonBreakingSpaces(tapText)),
        waitText: waitText,
        skipScreenshot: skipScreenshot,
        overwriteTimeout: overwriteTimeout,
      );
    }
  }

  /// Taps on Floating Action Button in Chats
  Future<void> tapFAB({
    String? waitText,
    bool? skipScreenshot,
  }) async {
    print('tapping on FAB');
    await tapType(
      'FloatingActionButton',
      waitText: waitText,
      skipScreenshot: skipScreenshot,
    );
  }

  /// Taps on widget after it localizes it via find.byType(type)
  Future<void> tapType(
    String type, {
    String? waitText,
    bool? skipScreenshot,
    Duration? overwriteTimeout,
  }) async {
    print('tapping on type: $tapType');
    await tapFinder(
      find.byType(type),
      waitText: waitText,
      skipScreenshot: skipScreenshot,
      overwriteTimeout: overwriteTimeout,
    );
  }

  /// Taps on widget after it localizes it via find.byValueKey(key)
  Future<void> tapKey(
    String key, {
    String? waitText,
    bool? skipScreenshot,
    Duration? overwriteTimeout,
  }) async {
    print('tapping on key: $key');
    try {
      await tapFinder(
        find.byValueKey(key),
        waitText: waitText,
        skipScreenshot: skipScreenshot,
        overwriteTimeout: overwriteTimeout,
      );
    } catch (e) {
      print(e);
    }
  }

  /// Simulates a long press is simulated, and screenshots labeled as 'long_press' are saved.
  /// It receives either a SerializableFinder or a text to look for using find.text()
  Future<void> longPress({required dynamic target}) async {
    SerializableFinder finder;
    if (target is SerializableFinder) {
      finder = target;
      print(
        'simulating long press at ${target.serialize()}, times out after $veryLongWaitTimeout',
      );
    } else if (target is String) {
      // we have a String text we will use to find the widget with - take into consideration we have to handle the breaking spaces case
      print(
        'simulating long press at text $target, times out after $veryLongWaitTimeout',
      );
      try {
        finder = find.text(target);
      } catch (_) {
        finder = find.text(addNonBreakingSpaces(target));
      }
    } else {
      return;
    }
    try {
      // running this as chained futures in order to be able to capture a screenshot of the long press state before it completes
      await captureScreenshotDuringFuture(
        futureToScreenshot: scroll(
          finder,
          0,
          0,
          longWaitTimeout,
          timeout: veryLongWaitTimeout,
        ),
        screenshotTitle: 'long_press',
      );
    } catch (e) {
      print(e);
    }
  }

  /// receives a SerializableFinder finder and taps at the center of the widget located by it. It handles text wrapping in case the finder can't locate the target.
  /// It saves a screenshot of the viewport unless skipScreenshot = true
  Future<void> tapFinder(
    SerializableFinder finder, {
    String? waitText,
    bool? skipScreenshot,
    Duration? overwriteTimeout,
  }) async {
    try {
      await tap(
        finder,
        timeout: overwriteTimeout ?? defaultTapTimeout,
      );
      if (waitText != null) {
        // TODO: add timeout here
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
    print('scrolling until $text is visible');
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

  /// Simple delay for [seconds]
  Future<void> waitForSeconds(int seconds) async {
    print('will now wait for $seconds seconds');
    await Future.delayed(Duration(seconds: seconds));
  }

  /// Automates the Developer → RESET FLAGS → Chats → GET STARTED → NEXT flow
  Future<void> resetFlagsAndEnrollAgain({bool? skipScreenshot}) async {
    print('do the whole reset -> enroll thing');
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

  /// Locates message bar, types a message and sends it, also saves screenshot with title "sending_message"
  Future<void> typeAndSend(
    String messageContent, {
    Duration? overwriteTimeout,
  }) async {
    await waitForSeconds(2);
    await tapType(
      'TextFormField',
      overwriteTimeout: overwriteTimeout,
    );
    // running this as chained futures in order to be able to capture a screenshot of the state before the first future completes
    await captureScreenshotDuringFuture(
      futureToScreenshot: enterText(
        messageContent,
        timeout: overwriteTimeout ?? const Duration(seconds: 1),
      ),
      screenshotTitle: 'sending_message',
    );
    await tapKey(
      'send_message',
      overwriteTimeout: overwriteTimeout,
    );
  }

  Future<void> captureScreenshotDuringFuture({
    required Future<void> futureToScreenshot,
    required String screenshotTitle,
  }) async {
    print('making sure we screenshot the future that is currently running');
    await Future.wait([
      futureToScreenshot,
      saveScreenshot(
        screenshotTitle,
      )
    ]);
  }

  Future<void> screenshotChatsView() async {
    print('screenshotting Chats view');
    await captureScreenshotDuringFuture(
      futureToScreenshot: waitForSeconds(1),
      screenshotTitle: 'init_test',
    );
  }

  Future<SerializableFinder> firstMessageFinder() async {
    final chats_messages_list = find.byValueKey('chats_messages_list');
    final first_message = find.descendant(
      of: chats_messages_list,
      matching: find.byType('ListItemFactory'),
      firstMatchOnly: true,
    );
    return first_message;
  }

  Future<void> tapFirstMessage() async {
    print('access first message of list');
    await tapFinder(
      await firstMessageFinder(),
      overwriteTimeout: defaultWaitTimeout,
    );
  }

  Future<void> longPressFirstMessage() async {
    await longPress(target: await firstMessageFinder());
  }
}
