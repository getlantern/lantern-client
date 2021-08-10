import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/new_message.dart';
import 'package:lantern/messaging/widgets/contact_message_preview.dart';
import 'package:lantern/ui/app.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:i18n_extension/i18n_widget.dart';
export 'package:lantern/i18n/i18n.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  group('Conversation Page Test', () {
    testWidgets(
        'Navigate from Messages Page into New Message Page into Conversation Page',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester.tap(find.widgetWithText(ContactMessagePreview, 'Me'));
      await tester.pumpAndSettle();
      expect(find.byType(Conversation), findsOneWidget);
    });

    testWidgets('Input message to send', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester.tap(find.widgetWithText(ContactMessagePreview, 'Me'));
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
    });

    testWidgets('Go back using physical button to New Message Page',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
    });
  });
}
