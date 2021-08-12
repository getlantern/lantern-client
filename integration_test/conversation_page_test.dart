import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/new_message.dart';
import 'package:lantern/messaging/widgets/contact_message_preview.dart';
import 'package:lantern/messaging/widgets/message_bubble.dart';
import 'package:lantern/messaging/widgets/message_types/content_container.dart';
import 'package:lantern/ui/app.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:i18n_extension/i18n_widget.dart';
export 'package:lantern/i18n/i18n.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  group('Conversation Page Test', () {
    Future<void> waitUntilSended(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
    }

    testWidgets(
        'Navigate from Messages Page into New Message Page into Conversation Page',
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
      expect(find.byType(Conversation), findsOneWidget);
    });

    testWidgets('Input message to send and evaluate if the text was received',
        (WidgetTester tester) async {
      final sendButtonFinder = find.byKey(const ValueKey('send_message'));
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await tester.pumpAndSettle();
      print('Enter `hello this a message send from Flutter Test`');
      await tester.enterText(find.byType(TextFormField),
          'hello this a message send from Flutter Test');
      await tester.pump();
      print(
          'await 2 seconds just to visualize the message in our TextFormField');
      await tester.pump(const Duration(seconds: 2));
      var textformfield =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textformfield.controller!.text,
          equals('hello this a message send from Flutter Test'));
      await tester.tap(sendButtonFinder);
      print('message has been send');
      await waitUntilSended(tester);
      print('check if MessageBubble was rendered');
      expect(find.byType(MessageBubble), findsOneWidget);
      print('Conversation should have a new widget with a text message');
      expect(
          find.widgetWithText(
              ContentContainer, 'hello this a message send from Flutter Test'),
          findsOneWidget);
    });

    testWidgets('Go back using physical button to New Message Page',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
    });
  });
}
