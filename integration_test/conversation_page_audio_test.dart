import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/new_message.dart';
import 'package:lantern/messaging/widgets/contact_message_preview.dart';
import 'package:lantern/messaging/widgets/message_bubble.dart';
import 'package:lantern/messaging/widgets/message_types/content_container.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/messaging/widgets/voice_recorder/audio_widget.dart';
import 'package:lantern/ui/app.dart';
import 'package:lantern/utils/waveform/wave_progress_bar.dart';

import 'helper_test.dart';
import 'mock_clipboard.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:i18n_extension/i18n_widget.dart';
export 'package:lantern/i18n/i18n.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  group('Conversation Page Test', () {
    MockClipboard? mockClipboard;

    setUp(() {
      mockClipboard = MockClipboard();
      SystemChannels.platform
          .setMockMethodCallHandler(mockClipboard?.handleMethodCall);
    });

    testWidgets('Check for an audio preview being rendered',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await tester.pumpAndSettle();
      print('We should hold the recording button for 5 seconds');
      print(
          'Since flutter test don\'t have anything that ressemble a hold for X seconds event');
      print(
          'We use a timedDrag which in theory does the same, but we need to add +1 seconds due to the movement of the virtual pointer');
      await tester.timedDrag(
          find.byKey(
            const ValueKey('btnRecord'),
          ),
          tester.getCenter(find.byKey(const ValueKey('btnRecord'))),
          const Duration(seconds: 6));
      await tester.pumpAndSettle();
      print('We should be able to see the options to delete or send an audio');
      expect(
          find.widgetWithIcon(GestureDetector, Icons.delete), findsOneWidget);
      expect(find.widgetWithIcon(GestureDetector, Icons.send), findsOneWidget);
      print('We should be able to see the waveform rendered');
      expect(find.byType(AudioWidget), findsOneWidget);
    });

    testWidgets(
        'Check if the audio can be played and the wave components should match with the slider',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await tester.pumpAndSettle();
      print('We should hold the recording button for 5 seconds');
      print(
          'Since flutter test don\'t have anything that ressemble a hold for X seconds event');
      print(
          'We use a timedDrag which in theory does the same, but we need to add +1 seconds due to the movement of the virtual pointer');
      await tester.timedDrag(
          find.byKey(
            const ValueKey('btnRecord'),
          ),
          tester.getCenter(find.byKey(const ValueKey('btnRecord'))),
          const Duration(seconds: 6));
      await tester.pumpAndSettle();
      print('Press the play button');
      await tester.tap(find.widgetWithIcon(TextButton, Icons.play_arrow));
      print('We wait 3 seconds and then press on the pause button');
      print(
          'This should be approximately 33% or a little more of the whole audio duration');
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.widgetWithIcon(TextButton, Icons.pause));
      await tester.pumpAndSettle();
      expect(find.byType(Slider), findsOneWidget);
      var slider = tester.widget<Slider>(find.byType(Slider));
      var waveform =
          tester.widget<WaveProgressBar>(find.byType(WaveProgressBar));
      print(
          'Check if the value progress for the SLIDER and WAVEPROGRESSBAR is the same');
      //check if progressPercentage is in a range.
      expect((waveform).progressPercentage, greaterThanOrEqualTo(33));
      expect((slider).value, greaterThanOrEqualTo(33));
    });

    testWidgets('Delete an AudioPreview', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await tester.pumpAndSettle();
      print('We should hold the recording button for 5 seconds');
      print(
          'Since flutter test don\'t have anything that ressemble a hold for X seconds event');
      print(
          'We use a timedDrag which in theory does the same, but we need to add +1 seconds due to the movement of the virtual pointer');
      await tester.timedDrag(
          find.byKey(
            const ValueKey('btnRecord'),
          ),
          tester.getCenter(find.byKey(const ValueKey('btnRecord'))),
          const Duration(seconds: 6));
      await tester.pumpAndSettle();
      print('Press the play button');
      await tester.tap(find.widgetWithIcon(TextButton, Icons.play_arrow));
      print('We wait 2 seconds and then press on the pause button');
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.widgetWithIcon(TextButton, Icons.pause));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(GestureDetector, Icons.delete));
      await tester.pumpAndSettle();
      expect(find.byType(Slider), findsNothing);
      expect(find.byType(WaveProgressBar), findsNothing);
    });

    testWidgets('Send an AudioPreview', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await tester.pumpAndSettle();
      print('We should hold the recording button for 5 seconds');
      print(
          'Since flutter test don\'t have anything that ressemble a hold for X seconds event');
      print(
          'We use a timedDrag which in theory does the same, but we need to add +1 seconds due to the movement of the virtual pointer');
      await tester.timedDrag(
          find.byKey(
            const ValueKey('btnRecord'),
          ),
          tester.getCenter(find.byKey(const ValueKey('btnRecord'))),
          const Duration(seconds: 6));
      await tester.pumpAndSettle();
      print('Press the send button');
      await tester.tap(find.widgetWithIcon(GestureDetector, Icons.send));
      await waitUntilSended(tester);
      expect(find.byType(MessageBubble), findsOneWidget);
    });

    testWidgets('Play the audio bubble', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      print('Press the play button');
      await tester.tap(find.widgetWithIcon(TextButton, Icons.play_arrow));
      print('We wait 3 seconds and then press on the pause button');
      print(
          'This should be approximately 33% or a little more of the whole audio duration');
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.widgetWithIcon(TextButton, Icons.pause));
      await waitUntilSended(tester);
      expect(find.byType(Slider), findsOneWidget);
      var slider = tester.widget<Slider>(find.byType(Slider));
      var waveform =
          tester.widget<WaveProgressBar>(find.byType(WaveProgressBar));
      print(
          'Check if the value progress for the SLIDER and WAVEPROGRESSBAR is the same');
      //check if progressPercentage is in a range.
      expect((waveform).progressPercentage, greaterThanOrEqualTo(33));
      expect((slider).value, greaterThanOrEqualTo(33));
    });
  });
}
