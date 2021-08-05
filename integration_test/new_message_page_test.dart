import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/messaging/messages.dart';
import 'package:lantern/messaging/new_message.dart';
import 'package:lantern/messaging/widgets/contact_message_preview.dart';
import 'package:lantern/ui/app.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:i18n_extension/i18n_widget.dart';
export 'package:lantern/i18n/i18n.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  group('New Message Test', () {
    testWidgets('Navigate from Messages Page into New Message Page',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(NewMessage), findsOneWidget);
    });

    testWidgets(
        'Check for components loaded correctly on New Message Page AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      print(
          'We use 2 pump and settle due to the elevated number of process that must been done on Android before starting flutter.');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      print('Search for a CustomAppBar');
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'New Message'), findsOneWidget);
      print('Search and QR should be displayed');
      expect(find.byIcon(Icons.search), findsWidgets);
      expect(find.byIcon(Icons.qr_code), findsWidgets);
    });

    testWidgets('Check for the body components on New Message Page',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      print(
          'We use 2 pump and settle due to the elevated number of process that must been done on Android before starting flutter.');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      print('We have 1 contact registered');
      expect(find.text('Recent contacts'.toUpperCase()), findsOneWidget);
      var contactList = tester.widget<ListView>(find.byType(ListView));
      print('The list should have 1 element');
      expect(contactList.semanticChildCount, equals(1));
      print('We check if the ListView can be scrollable');
      print('Manually scrolling 200 pixels down');
      await tester.drag(find.byType(ListView), const Offset(0.0, -300.0));
      print('Flush the widget tree');
      await tester.pumpAndSettle();
      var contactElement = find.widgetWithText(ContactMessagePreview, 'me');
      expect(contactElement, findsOneWidget);
    });

    testWidgets('Go back using physical button to Messages Page',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(Messages), findsOneWidget);
    });
  });
}
