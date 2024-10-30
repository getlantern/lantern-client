import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/core/utils/common.dart' as common;
import 'package:lantern/features/messaging/chats.dart';
import 'package:lantern/features/messaging/contacts/new_chat.dart';

import 'action/navigation_action_test.dart';
import 'enums/screens_test.dart';

export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:i18n_extension/i18n_widget.dart';
export 'package:lantern/core/localization/i18n.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  group('New Message Test', () {
    testWidgets('Navigate from Messages Page into New Message Page',
        (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.MESSAGES,
        to: SCREENS.CONTACTS,
      );
      expect(find.byType(NewChat), findsOneWidget);
    });

    testWidgets(
        'Check for components loaded correctly on New Message Page AppBar',
        (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.MESSAGES,
        to: SCREENS.CONTACTS,
      );
      print('Search for a CustomAppBar');
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'New Message'), findsOneWidget);
      print('Search and QR should be displayed');
      // TODO: This is outdated, needs fix
      expect(find.byIcon(Icons.search), findsWidgets);
      // TODO: This is outdated, needs fix
      expect(find.byIcon(Icons.qr_code), findsWidgets);
    });

    testWidgets('Check for the body components on New Message Page',
        (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.MESSAGES,
        to: SCREENS.CONTACTS,
      );
      expect(
        find.text('Recent contacts'.toUpperCase()),
        findsOneWidget,
        reason: 'We have 1 contact registered',
      );
      var contactList = tester.widget<ListView>(find.byType(ListView));
      expect(
        contactList.semanticChildCount,
        equals(1),
        reason: 'The list should have 1 element',
      );
      print('We check if the ListView can be scrollable');
      print('Manually scrolling 200 pixels down');
      await tester.drag(find.byType(ListView), const Offset(0.0, -300.0));
      print('Flush the widget tree');
      await tester.pumpAndSettle();
      var contactElement =
          find.widgetWithText(common.ListItemFactory, 'Note to self');
      expect(contactElement, findsOneWidget);
    });

    testWidgets('Go back using physical button to Messages Page',
        (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      await GoTo.navigateTo(
        tester,
        from: SCREENS.MESSAGES,
        to: SCREENS.CONTACTS,
      );
      await GoTo.navigateBack(tester);
      expect(find.byType(Chats), findsOneWidget);
    });
  });
}
