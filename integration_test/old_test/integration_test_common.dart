import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:lantern/core/utils/add_nonbreaking_spaces.dart';
import 'package:lantern/flutter_driver_extensions/add_dummy_contacts_command.dart';
import 'package:lantern/flutter_driver_extensions/navigate_command.dart';
import 'package:lantern/flutter_driver_extensions/reset_flags_command.dart';
import 'package:lantern/flutter_driver_extensions/send_dummy_files_command.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'integration_test_constants.dart';

export 'package:flutter_driver/flutter_driver.dart';
export 'package:test/test.dart';

Future<FlutterDriver> connect({int port = 8888}) async {
  return await FlutterDriver.connect(
    dartVmServiceUrl: 'http://127.0.0.1:$port',
    timeout: const Duration(seconds: 15),
  );
}

/// Scaffolds the test workflow
Future<void> runTest(
  Future<void> Function(FlutterDriver driver) doTest, {
  Timeout timeout = const Timeout(Duration(minutes: 5)),
}) async {
  final name = Platform.script.pathSegments.last.replaceAll('_test.dart', '');

  late FlutterDriver driver;

  setUpAll(() async {
    // Connect to a running Flutter application instance.
    driver = await connect();
    await driver.initScreenshotsDirectory(name);
  });

  tearDownAll(() async {
    await driver.close();
  });

  group(name, () {
    test(
      name,
      () async {
        await doTest(driver);
      },
      timeout: timeout,
    );
  });
}

extension DriverExtension on FlutterDriver {
  static var screenshotSequence = 0;

  // screenshots for a given test are saved here
  static var currentTestDirPath = '';

  /// Custom flutter driver command for navigating to Home
  /// pops router all the way behind the scenes navigatorKey.currentContext?.router.popUntilRoot()
  Future<void> home() async {
    await sendCommand(NavigateCommand(NavigateCommand.home));
  }

  /// Custom flutter driver command for adding dummy contacts
  Future<void> addDummyContacts() async {
    print('adding dummy contacts');
    await sendCommand(AddDummyContactsCommand());
  }

  /// Custom flutter driver command for downloading and sharing an image and a video file in a conversation with one of the dummy contacts
  Future<void> sendDummyFiles() async {
    print('downloading and sharing dummy files');
    await sendCommand(SendDummyFilesCommand());
  }

  /// Custom flutter driver command that resets Chat flags and timestamps
  Future<void> resetFlags() async {
    print('resetting flags and timestamps');
    await sendCommand(ResetFlagsCommand());
  }

  /// Opens specified tab
  Future<void> openTab(
    String label, {
    bool homeFirst = false,
    bool skipScreenshot = false,
  }) async {
    if (homeFirst) {
      print('navigating to home');
      await home();
    }
    await tapText(
      label,
      skipScreenshot: skipScreenshot,
      parent: find.byType('CustomBottomBarItem'),
    );
  }

  /// iterates through our array of available locales and creates a folder for each locale
  Future<void> initLocaleFolders() async {
    languages.forEach((lang) async {
      final directory = Directory('screenshots/$lang');
      if (await directory.exists()) return;
      await directory.create();
    });
  }

  /// deletes and re-creates currentTestDirPath each time the test is run
  Future<void> initScreenshotsDirectory(String testName) async {
    currentTestDirPath = 'screenshots/$simulatedLocale/$testName';
    final directory = Directory(currentTestDirPath);
    if (await directory.exists()) await directory.delete(recursive: true);
    await directory.create(recursive: true);
  }

  /// saves screenshots to currentTestDirPath directory
  Future<void> saveScreenshot(String name) async {
    try {
      final png = await screenshot();
      final screenshotName = join(
        currentTestDirPath,
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

  /// Handles non-breaking text wrapping
  Future<void> doWaitForText(String waitText) async {
    final localizedWaitText = waitText;
    try {
      await waitFor(
        find.text(localizedWaitText),
        timeout: defaultWaitTimeout,
      );
    } catch (_) {
      // try it with non-breaking spaces like those added by CText
      try {
        await waitFor(
          find.text(addNonBreakingSpaces(localizedWaitText)),
          timeout: defaultWaitTimeout,
        );
      } catch (e) {
        print(e);
      }
    }
  }

  /// Taps on widget after it localizes it via find.text()
  Future<void> tapText(
    String tapText, {
    String? waitText,
    bool? skipScreenshot,
    Duration? overwriteTimeout,
    SerializableFinder? parent,
    bool capitalize = false,
  }) async {
    tapText = await requestData(tapText);
    if (capitalize) {
      tapText = tapText.toUpperCase();
    }
    waitText = waitText == null ? null : await requestData(waitText);
    print('tapping on text: $tapText');
    try {
      await tapFinder(
        find.text(tapText),
        waitText: waitText,
        skipScreenshot: skipScreenshot,
        overwriteTimeout: overwriteTimeout,
        parent: parent,
      );
    } catch (_) {
      // try it with non-breaking spaces like those added by CText
      await tapFinder(
        find.text(addNonBreakingSpaces(tapText)),
        waitText: waitText,
        skipScreenshot: skipScreenshot,
        overwriteTimeout: overwriteTimeout,
        parent: parent,
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
    print('tapping on type: $type');
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

  /// Finds and longpresses a specific string
  Future<void> longPressText(String text) async {
    await longPress(target: find.text(await requestData(text)));
  }

  /// Simulates a long press is simulated, and screenshots labeled as 'long_press' are saved.
  /// It receives either a SerializableFinder or a text to look for using find.text()
  Future<void> longPress({required dynamic target}) async {
    SerializableFinder finder;
    if (target is SerializableFinder) {
      finder = target;
      print(
        'simulating long press at ${target.serialize()}, times out after $longWaitTimeout',
      );
    } else if (target is String) {
      // we have a String text we will use to find the widget with - take into consideration we have to handle the breaking spaces case
      print(
        'simulating long press at text $target, times out after $longWaitTimeout',
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
          timeout: longWaitTimeout,
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
    SerializableFinder? parent,
  }) async {
    if (parent != null) {
      finder = find.descendant(of: parent, matching: finder);
    }
    try {
      await tap(
        finder,
        timeout: overwriteTimeout ?? defaultTapTimeout,
      );
      if (waitText != null) {
        await doWaitForText(waitText);
      }
    } catch (e) {
      print(e);
      rethrow;
    } finally {
      if (skipScreenshot == true) return;
      await saveScreenshot(
        'tap_${finder}_wait_for_$waitText',
      );
    }
  }

  /// Controls scrolling inside a ListView widget
  Future<void> scrollTextUntilVisible(String text) async {
    try {
      print('scrolling until $text is visible');
      final scrollable = find.byType('ListView');
      await waitFor(
        scrollable,
        timeout: defaultWaitTimeout,
      );
      await scrollUntilVisible(
        scrollable,
        find.text(await requestData(text)),
        dyScroll: -500,
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
    await openTab('Developer', homeFirst: true, skipScreenshot: true);
    await scrollTextUntilVisible('RESET FLAGS');
    await tapText(
      'RESET FLAGS',
      skipScreenshot: true,
    );
    await tapText(
      await requestData('chats'),
      skipScreenshot: skipScreenshot,
    );
    await tapText(
      (await requestData('get_started')).toUpperCase(),
      skipScreenshot: skipScreenshot,
    );
    await tapText(
      'next',
      capitalize: true,
      skipScreenshot: skipScreenshot,
    );
  }

  /// Locates message bar, types a message and sends it, also saves screenshot with title "sending_message"
  Future<void> typeAndSend(
    String messageContent, {
    Duration? overwriteTimeout,
  }) async {
    messageContent = await requestData(messageContent);
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

  /// creates an array for Futures, one of which is what we want to save a screenshot of, and the other is the saveScreenshot() function
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

  /// saves a screenshot of the current view and labels it "current_screen"
  Future<void> screenshotCurrentView() async {
    print('screenshotting current view');
    await captureScreenshotDuringFuture(
      futureToScreenshot: waitForSeconds(1),
      screenshotTitle: 'current_screen',
    );
  }

  /// finds first item of descendants in list with given list_key
  Future<SerializableFinder> fistItemFinder(String list_key) async {
    final list = find.byValueKey(list_key);
    final firstItem = find.descendant(
      of: list,
      matching: find.byType('ListItemFactory'),
      firstMatchOnly: true,
    );
    return firstItem;
  }

  /// taps first item of descendants in list with given list_key
  Future<void> tapFirstItemInList(String list_key) async {
    print('access first message of list with $list_key key');
    await tapFinder(
      await fistItemFinder(list_key),
      overwriteTimeout: defaultWaitTimeout,
    );
  }

  /// long presses first item of descendants in list with given list_key
  Future<void> longPressFirstItemInList(String list_key) async {
    await longPress(target: await fistItemFinder(list_key));
  }
}
