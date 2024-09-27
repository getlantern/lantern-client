import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/features/messaging/contacts/new_chat.dart';
import 'package:lantern/features/messaging/conversation/conversation.dart';

import 'action/input_test.dart';
import 'action/navigation_action_test.dart';
import 'enums/disappearing_test.dart';
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

    testWidgets(
        'Navigate from Messages Page into New Message Page into Conversation Page',
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
      expect(find.byType(Conversation), findsOneWidget);
    });

    testWidgets('Input message to send and evaluate if the text was received',
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
      await Input.setTextMessage(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        seconds: 2,
        visualize: true,
      );
      await Input.sendMessage(
        tester,
        find,
        checkForBubble: true,
        text: 'hello this is a message from Flutter Test',
      );
    });

    testWidgets('Remove the message sended just for me',
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
      await Input.removeMessageForMe(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        checkDialog: true,
        optionTitle: 'Delete for me',
        removeBtnTitle: 'delete'.toUpperCase(),
      );
    });

    testWidgets('Copy the content into the Clipboard event',
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
      await Input.setTextMessage(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        seconds: 2,
        visualize: true,
      );
      await Input.sendMessage(
        tester,
        find,
        checkForBubble: true,
        text: 'hello this is a message from Flutter Test',
      );
      await Input.copyTextMessage(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        optionTitle: 'Copy Text',
      );
      await Input.checkClipboard(
        tester,
        find,
        mockClipboard!,
        text: 'hello this is a message from Flutter Test',
      );
    });

    testWidgets('Test preset reactions', (WidgetTester tester) async {
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
      await Input.setReaction(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        reaction: '👍',
      );
      await GoTo.navigateBack(tester);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.CONTACTS,
        to: SCREENS.CONVERSATION,
      );
      await Input.setReaction(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        reaction: '👎',
      );
      await GoTo.navigateBack(tester);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.CONTACTS,
        to: SCREENS.CONVERSATION,
      );
      await Input.setReaction(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        reaction: '😄',
      );
      await GoTo.navigateBack(tester);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.CONTACTS,
        to: SCREENS.CONVERSATION,
      );
      await Input.setReaction(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        reaction: '❤',
      );
      await GoTo.navigateBack(tester);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.CONTACTS,
        to: SCREENS.CONVERSATION,
      );
      await Input.setReaction(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        reaction: '😢',
      );
      await GoTo.navigateBack(tester);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.CONTACTS,
        to: SCREENS.CONVERSATION,
      );
      await Input.setReaction(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        customReaction: '😉',
        reaction: '•••',
        isCustomReaction: true,
      );
    });

    testWidgets(
        'Remove a reply intent for the message "hello this is a message send from Flutter Test"',
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
      await Input.setReply(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        checkReply: true,
        optionTitle: 'Reply',
      );
      await Input.closeReply(tester, find, key: 'close_reply');
    });

    testWidgets(
        'Send a reply intent for the message "hello this is a message send from Flutter Test"',
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
      await Input.setReply(
        tester,
        find,
        text: 'hello this is a message from Flutter Test',
        checkReply: true,
        optionTitle: 'Reply',
      );
      await Input.setTextMessage(
        tester,
        find,
        text: 'Replying: TERI TERI! DAISHORI!! :D',
        seconds: 2,
        visualize: true,
      );
      await Input.sendMessage(
        tester,
        find,
        checkForBubble: true,
        text: 'Replying: TERI TERI! DAISHORI!! :D',
      );
    });

    testWidgets('Set a disappearing time and wait till is gone',
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
      await Input.setDisappearingMessage(
        tester,
        find,
        key: 'disappearingSelect',
        checkDurationStatus: true,
        disappearing: DISAPPEARING.SECONDS_5,
      );
      await Input.setTextMessage(
        tester,
        find,
        text: 'This will be shortly gone',
        seconds: 1,
        visualize: true,
      );
      await Input.sendMessage(
        tester,
        find,
        checkForBubble: true,
        text: 'This will be shortly gone',
      );
      await Input.checkRemovedTextMessageWithDelay(
        tester,
        find,
        delay: const Duration(seconds: 5),
        text: 'This will be shortly gone',
      );
    });

    testWidgets('Send a custom emoji', (WidgetTester tester) async {
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
      await Input.setTextMessage(
        tester,
        find,
        emojiSelection: '😇',
        seconds: 2,
        visualize: true,
      );
      await Input.sendMessage(tester, find, checkForBubble: true, text: '😇');
    });

    testWidgets('Go back using physical button to New Message Page',
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
      await GoTo.navigateBack(tester);
      expect(find.byType(NewChat), findsOneWidget);
    });
  });
}
