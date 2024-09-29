import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'action/input_test.dart';
import 'action/navigation_action_test.dart';
import 'enums/screens_test.dart';
import 'helpers/clipboard_test.dart';

export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:i18n_extension/i18n_widget.dart';
export 'package:lantern/core/localization/i18n.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  group('Conversation Page Test', () {
    ClipboardMock? mockClipboard;

    setUp(() {
      mockClipboard = ClipboardMock();
      SystemChannels.platform
          .setMockMethodCallHandler(mockClipboard?.handleMethodCall);
    });

    testWidgets('Check for an audio preview being rendered',
        (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.MESSAGES,
        to: SCREENS.CONTACTS,
      );
      await GoTo.navigateTo(
        tester,
        from: SCREENS.CONTACTS,
        to: SCREENS.CONVERSATION,
      );
      await Input.startRecording(
        tester,
        find,
        checkAudioPreviewComponents: true,
        key: 'btnRecord',
        recordFor: const Duration(seconds: 6),
      );
    });

    testWidgets(
        'Check if the audio can be played and the wave components should match with the slider',
        (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.MESSAGES,
        to: SCREENS.CONTACTS,
      );
      await GoTo.navigateTo(
        tester,
        from: SCREENS.CONTACTS,
        to: SCREENS.CONVERSATION,
      );
      await Input.startRecording(
        tester,
        find,
        checkAudioPreviewComponents: true,
        key: 'btnRecord',
        recordFor: const Duration(seconds: 6),
      );
      await Input.playAudioPreview(
        tester,
        find,
        checkAudioPreviewComponents: true,
        expectedAudioCompletion: 33,
        playFor: const Duration(seconds: 3),
      );
    });

    testWidgets('Delete an AudioPreview', (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.MESSAGES,
        to: SCREENS.CONTACTS,
      );
      await GoTo.navigateTo(
        tester,
        from: SCREENS.CONTACTS,
        to: SCREENS.CONVERSATION,
      );
      await Input.startRecording(
        tester,
        find,
        checkAudioPreviewComponents: true,
        key: 'btnRecord',
        recordFor: const Duration(seconds: 6),
      );
      await Input.playAudioPreview(
        tester,
        find,
        checkAudioPreviewComponents: true,
        expectedAudioCompletion: 33,
        playFor: const Duration(seconds: 3),
      );
      await Input.deleteAudioPreview(
        tester,
        find,
        checkAudioPreviewComponents: true,
      );
    });

    testWidgets('Send an AudioPreview', (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.MESSAGES,
        to: SCREENS.CONTACTS,
      );
      await GoTo.navigateTo(
        tester,
        from: SCREENS.CONTACTS,
        to: SCREENS.CONVERSATION,
      );
      await Input.startRecording(
        tester,
        find,
        checkAudioPreviewComponents: true,
        key: 'btnRecord',
        recordFor: const Duration(seconds: 5),
      );
      await Input.sendMessage(
        tester,
        find,
        checkForBubble: true,
        isAudio: true,
      );
    });

    testWidgets('Play the audio bubble', (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      await tester.pump(const Duration(seconds: 20));
      await GoTo.navigateTo(
        tester,
        from: SCREENS.MESSAGES,
        to: SCREENS.CONVERSATION,
      );
      await Input.playAudioPreview(
        tester,
        find,
        checkAudioPreviewComponents: true,
        expectedAudioCompletion: 33,
        playFor: const Duration(seconds: 3),
      );
    });
  });
}
