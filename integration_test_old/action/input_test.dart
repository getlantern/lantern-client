import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/features/messaging/conversation/audio/audio_widget.dart';
import 'package:lantern/features/messaging/conversation/audio/waveform.dart';
import 'package:lantern/features/messaging/conversation/message_bubble.dart';
import 'package:lantern/features/messaging/conversation/status_row.dart';

import '../enums/disappearing_test.dart';
import '../helpers/clipboard_test.dart';
import '../helpers/waiter_test.dart';

class Input {
  static Future<void> setTextMessage(
    WidgetTester tester,
    CommonFinders find, {
    String text = '',
    String? emojiSelection,
    bool visualize = false,
    int seconds = 0,
  }) async {
    var textformfield =
        tester.widget<TextFormField>(find.byType(TextFormField));
    if (emojiSelection == null) {
      await tester.enterText(find.byType(TextFormField), text);
    } else {
      // TODO: This is outdated, needs fix
      await tester.tap(find.byIcon(Icons.sentiment_very_satisfied));
      await awaitFor(tester, duration: const Duration(seconds: 1));
      await tester.tap(find.text(emojiSelection));
      await awaitFor(tester, duration: const Duration(seconds: 1));
    }
    await tester.pump();
    if (visualize) {
      await awaitFor(tester, duration: Duration(seconds: seconds));
    }
    expect(textformfield.controller?.text, equals(emojiSelection ?? text));
  }

  static Future<void> checkRemovedTextMessageWithDelay(
    WidgetTester tester,
    CommonFinders find, {
    String text = '',
    Duration delay = Duration.zero,
  }) async {
    await Future.delayed(delay);
    await awaitFor(tester, duration: const Duration(seconds: 1));
    expect(find.widgetWithText(MessageBubble, text), findsNothing);
  }

  static Future<void> setDisappearingMessage(
    WidgetTester tester,
    CommonFinders find, {
    String key = '',
    DISAPPEARING disappearing = DISAPPEARING.SECONDS_5,
    bool checkDurationStatus = false,
  }) async {
    await tester.tap(find.byKey(Key(key)));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    await tester
        .tap(find.widgetWithText(ListTile, disappearMap[disappearing]!));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    if (checkDurationStatus) {
      expect(find.text(disappearMapReduced[disappearing]!), findsOneWidget);
    }
  }

  static Future<void> sendMessage(
    WidgetTester tester,
    CommonFinders find, {
    bool checkForBubble = false,
    isAudio = false,
    String? text,
  }) async {
    if (isAudio) {
      await tester.tap(find.widgetWithIcon(GestureDetector, Icons.send));
    } else {
      final sendButtonFinder = find.byKey(const ValueKey('send_message'));
      await tester.tap(sendButtonFinder);
    }
    await awaitFor(tester, duration: const Duration(seconds: 1));
    if (checkForBubble) {
      if (text != null) {
        expect(find.widgetWithText(MessageBubble, text), findsOneWidget);
      }
      if (isAudio) {
        print('await for the audio to be sended');
        await awaitFor(tester, duration: const Duration(seconds: 2));
        print('await for the audio to be playable');
        await awaitFor(tester, duration: const Duration(seconds: 2));
        await awaitFor(tester, duration: const Duration(seconds: 2));
        expect(find.byType(Waveform), findsOneWidget);
      }
    }
  }

  static Future<void> removeMessageForMe(
    WidgetTester tester,
    CommonFinders find, {
    String text = '',
    optionTitle = '',
    removeBtnTitle = '',
    bool checkDialog = false,
  }) async {
    await tester.longPress(find.widgetWithText(MessageBubble, text));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    await tester.tap(find.text(optionTitle));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    if (checkDialog) {
      expect(find.byType(AlertDialog), findsOneWidget);
    }
    await tester.tap(find.text(removeBtnTitle));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    expect(find.widgetWithText(MessageBubble, text), findsNothing);
  }

  static Future<void> copyTextMessage(
    WidgetTester tester,
    CommonFinders find, {
    String text = '',
    optionTitle = '',
  }) async {
    await tester.longPress(find.widgetWithText(MessageBubble, text));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    await tester.tap(find.text(optionTitle));
    await tester.pump();
  }

  static Future<void> setReply(
    WidgetTester tester,
    CommonFinders find, {
    String text = '',
    optionTitle = '',
    bool checkReply = false,
  }) async {
    await tester.longPress(find.widgetWithText(MessageBubble, text));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    await tester.tap(find.text(optionTitle));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    if (checkReply) {
      expect(find.widgetWithText(Row, 'Replying to me'), findsOneWidget);
    }
  }

  static Future<void> closeReply(
    WidgetTester tester,
    CommonFinders find, {
    String key = '',
  }) async {
    await tester.tap(find.byKey(Key(key)));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    expect(find.widgetWithText(Row, 'Replying to me'), findsNothing);
  }

  static Future<void> setReaction(
    WidgetTester tester,
    CommonFinders find, {
    String text = '',
    reaction = '',
    customReaction,
    bool isCustomReaction = false,
  }) async {
    await tester.longPress(find.widgetWithText(MessageBubble, text));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    await tester.tap(find.byKey(Key(reaction)));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    if (isCustomReaction) {
      await tester.tap(find.text(customReaction));
      await awaitFor(tester, duration: const Duration(seconds: 1));
    }
    expect(
      find.widgetWithText(StatusRow, customReaction ?? reaction),
      findsOneWidget,
    );
  }

  static Future<void> startRecording(
    WidgetTester tester,
    CommonFinders find, {
    String key = '',
    Duration recordFor = Duration.zero,
    bool checkAudioPreviewComponents = false,
  }) async {
    await tester.timedDrag(
      find.byKey(
        Key(key),
      ),
      tester.getCenter(find.byKey(Key(key))),
      recordFor,
    );
    await tester.pumpAndSettle();
    if (checkAudioPreviewComponents) {
      expect(
        find.widgetWithIcon(GestureDetector, Icons.delete),
        findsOneWidget,
      );
      expect(find.widgetWithIcon(GestureDetector, Icons.send), findsOneWidget);
      expect(find.byType(AudioWidget), findsOneWidget);
    }
  }

  static Future<void> playAudioPreview(
    WidgetTester tester,
    CommonFinders find, {
    Duration playFor = Duration.zero,
    bool checkAudioPreviewComponents = false,
    int expectedAudioCompletion = 0,
  }) async {
    await tester.tap(find.widgetWithIcon(TextButton, Icons.play_arrow));
    await tester.pump(playFor);
    await tester.tap(find.widgetWithIcon(TextButton, Icons.pause));
    await awaitFor(tester, duration: const Duration(seconds: 1));
    if (checkAudioPreviewComponents) {
      expect(find.byType(Slider), findsOneWidget);
      var slider = tester.widget<Slider>(find.byType(Slider));
      var waveform = tester.widget<Waveform>(find.byType(Waveform));
      expect((waveform).progressPercentage, greaterThanOrEqualTo(33));
      expect((slider).value, greaterThanOrEqualTo(expectedAudioCompletion));
    }
  }

  static Future<void> deleteAudioPreview(
    WidgetTester tester,
    CommonFinders find, {
    bool checkAudioPreviewComponents = false,
  }) async {
    await tester.tap(find.widgetWithIcon(GestureDetector, Icons.delete));
    await tester.pumpAndSettle();
    if (checkAudioPreviewComponents) {
      expect(find.byType(Slider), findsNothing);
      expect(find.byType(Waveform), findsNothing);
    }
  }

  static Future<void> checkClipboard(
    WidgetTester tester,
    CommonFinders find,
    ClipboardMock clipboard, {
    String text = '',
  }) async {
    expect(
      clipboard.clipboardData,
      equals(
        {'text': text},
      ),
    );
  }
}
