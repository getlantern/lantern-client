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

    testWidgets('Remove the message sended just for me',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          ContentContainer, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the option "DELETE FOR ME"');
      await tester.tap(find.text('Delete for me'));
      print('Refresh the screen after doing a tap on "DELETE FOR ME"');
      await waitUntilSended(tester);
      print(
          'We should see an AlertDialog with a text "This will delete the message for you only. Everyone else will still be able to see it."');
      expect(find.byType(AlertDialog), findsOneWidget);
      await waitUntilSended(tester);
      await tester.tap(find.text('Delete'));
      await waitUntilSended(tester);
      print('The alert dialog should has been dismissed');
      expect(find.byType(AlertDialog), findsNothing);
      print('We shouldn\'t have any bubble widget');
      expect(
          find.widgetWithText(
              ContentContainer, 'hello this a message send from Flutter Test'),
          findsNothing);
    });

    testWidgets('Input a message to send and evaluate if the text was received',
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

    testWidgets('Remove the message sended for everyone',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          ContentContainer, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the option "DELETE FOR EVERYONE"');
      await tester.tap(find.text('Delete for everyone'));
      print('Refresh the screen after doing a tap on "DELETE FOR EVERYONE"');
      await waitUntilSended(tester);
      print(
          'We should see an AlertDialog with a text "This will delete the message for everyone."');
      expect(find.byType(AlertDialog), findsOneWidget);
      await waitUntilSended(tester);
      await tester.tap(find.text('Delete'));
      await waitUntilSended(tester);
      print('The alert dialog should has been dismissed');
      expect(find.byType(AlertDialog), findsNothing);
      print('We shouldn\'t have any bubble widget');
      expect(
          find.widgetWithText(
              ContentContainer, 'hello this a message send from Flutter Test'),
          findsNothing);
    });

    testWidgets('Input a message to send and evaluate if the text was received',
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

    testWidgets('Copy the content into the Clipboard event',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          ContentContainer, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the option "COPY TEXT"');
      await tester.tap(find.text('Copy Text'));
      print('Refresh the screen after doing a tap on "COPY TEXT"');
      await tester.pump();
      print('We should see a Snackbar with a text "Copy Text"');
      expect(find.text('Text copied'), findsOneWidget);
      await waitUntilSended(tester);
      print('The clipboard should have the same content as our MessageBubble');
      expect(
        mockClipboard?.clipboardData,
        equals(
          {'text': 'hello this a message send from Flutter Test'},
        ),
      );
    });

    testWidgets('Generate a 👍 reaction', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          ContentContainer, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the 👍 reaction');
      await tester.tap(find.byKey(const ValueKey('👍')));
      print('Refresh the screen after doing a tap on "👍"');
      await waitUntilSended(tester);
      expect(find.widgetWithText(StatusRow, '👍'), findsOneWidget);
    });

    testWidgets('Generate a 👎 reaction', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          ContentContainer, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the 👎 reaction');
      await tester.tap(find.byKey(const ValueKey('👎')));
      print('Refresh the screen after doing a tap on "👎"');
      await waitUntilSended(tester);
      expect(find.widgetWithText(StatusRow, '👎'), findsOneWidget);
    });

    testWidgets('Generate a ❤ reaction', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          ContentContainer, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the ❤ reaction');
      await tester.tap(find.byKey(const ValueKey('❤')));
      print('Refresh the screen after doing a tap on "❤"');
      await waitUntilSended(tester);
      expect(find.widgetWithText(StatusRow, '❤'), findsOneWidget);
    });

    testWidgets('Generate a 😢 reaction', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          ContentContainer, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the 😢 reaction');
      await tester.tap(find.byKey(const ValueKey('😢')));
      print('Refresh the screen after doing a tap on "😢"');
      await waitUntilSended(tester);
      expect(find.widgetWithText(StatusRow, '😢'), findsOneWidget);
    });

    testWidgets('Generate a custom reaction from •••',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          ContentContainer, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the ••• reaction');
      await tester.tap(find.byKey(const ValueKey('•••')));
      print('Refresh the screen after doing a tap on "•••"');
      await waitUntilSended(tester);
      await tester.tap(find.text('🥰'));
      await waitUntilSended(tester);
      expect(find.widgetWithText(StatusRow, '🥰'), findsOneWidget);
    });

    testWidgets(
        'Remove a reply intent for the message "hello this is a message send from Flutter Test"',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          FocusedMenuHolder, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the reply option');
      await tester.tap(find.text('Reply'));
      print('Refresh the screen after doing a tap on "Reply"');
      await waitUntilSended(tester);
      print('Check if "Reply" was rendered');
      expect(find.widgetWithText(Row, 'Replying to me'), findsOneWidget);
      print('Close the reply intent');
      await tester.tap(find.byKey(const ValueKey('close_reply')));
      await waitUntilSended(tester);
      expect(find.widgetWithText(Row, 'Replying to me'), findsNothing);
    });

    testWidgets(
        'Send a reply intent for the message "hello this is a message send from Flutter Test"',
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
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          FocusedMenuHolder, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the reply option');
      await tester.tap(find.text('Reply'));
      print('Refresh the screen after doing a tap on "Reply"');
      await waitUntilSended(tester);
      print('Check if "Reply" was rendered');
      await tester.enterText(
          find.byType(TextFormField), 'Replying: TERI TERI! DAISHORI!! :D');
      await tester.pump();
      await tester.tap(sendButtonFinder);
      print('message has been send');
      await waitUntilSended(tester);
      expect(
          find.widgetWithText(Row, 'Replying to Note to self'), findsOneWidget);
      expect(
          find.widgetWithText(
              ContentContainer, 'Replying: TERI TERI! DAISHORI!! :D'),
          findsOneWidget);
    });

    testWidgets('Set a disappearing time and wait till is gone',
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
      await waitUntilSended(tester);
      await tester.tap(find.byKey(const ValueKey('disappearingSelect')));
      await waitUntilSended(tester);
      print('A dropdown should render');
      await tester.tap(find.widgetWithText(ListTile, '5 seconds'));
      await waitUntilSended(tester);
      print('Now we should have an indicator saying 5 seconds');
      expect(find.text('5S'), findsOneWidget);
      print('We write the text that is gonna be visible for 5 seconds');
      await tester.enterText(
          find.byType(TextFormField), 'This will be shortly gone');
      await tester.pump();
      await tester.tap(sendButtonFinder);
      print('message has been send');
      await waitUntilSended(tester);
      expect(find.widgetWithText(ContentContainer, 'This will be shortly gone'),
          findsOneWidget);
      await Future.delayed(const Duration(seconds: 5), () {});
      await waitUntilSended(tester);
      print('Check if the message has been removed');
      expect(find.widgetWithText(ContentContainer, 'This will be shortly gone'),
          findsNothing);
    });

    testWidgets('Generate a 😄 reaction', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.longPress(find.widgetWithText(
          ContentContainer, 'hello this a message send from Flutter Test'));
      await waitUntilSended(tester);
      print('Proceed to tap on the 😄 reaction');
      await tester.tap(find.byKey(const ValueKey('😄')));
      print('Refresh the screen after doing a tap on "😄"');
      await waitUntilSended(tester);
      expect(find.widgetWithText(StatusRow, '😄'), findsOneWidget);
    });

    testWidgets('Send a custom emoji', (WidgetTester tester) async {
      final sendButtonFinder = find.byKey(const ValueKey('send_message'));
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
      await tester
          .tap(find.widgetWithText(ContactMessagePreview, 'Note to self'));
      await waitUntilSended(tester);
      await tester.tap(find.byIcon(Icons.sentiment_very_satisfied));
      print('The emoji picker should appear');
      await waitUntilSended(tester);
      print('We tap on the "😆"');
      await tester.tap(find.text('😆'));
      await waitUntilSended(tester);
      var textformfield =
          tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textformfield.controller!.text, equals('😆'));
      await tester.tap(sendButtonFinder);
      print('message has been send');
      await waitUntilSended(tester);
      print('check if MessageBubble was rendered');
      expect(find.byType(MessageBubble), findsOneWidget);
      print('Conversation should have a new widget with a text message');
      expect(find.widgetWithText(ContentContainer, '😆'), findsOneWidget);
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
