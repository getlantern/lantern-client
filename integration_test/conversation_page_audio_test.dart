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

    /// This function is called during each new message, to ensure that the
    /// message is displayed correctly, we need to wait for the message to be
    /// displayed.
    Future<void> waitUntilSended(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('Check for an audio preview of 5 seconds',
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
  });
}
