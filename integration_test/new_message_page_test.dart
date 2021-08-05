import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/messaging/messages.dart';
import 'package:lantern/messaging/widgets/contact_message_preview.dart';
import 'package:lantern/ui/app.dart';
import 'package:lantern/ui/home.dart';
import 'package:lantern/ui/widgets/custom_bottom_bar.dart';
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
      print(
          'We use 2 pump and settle due to the elevated number of process that must been done on Android before starting flutter.');
      await tester.pumpAndSettle();
      print('Check if the AutoTabsScaffold is already on stage');
      var contactList = tester.widget<ListView>(find.byType(ListView));
      print('The list should be empty');
      expect(contactList, isEmpty);
      print(
          'The list should have 0 elements, because we don\'t have any ongoing chat');
      expect(contactList.semanticChildCount, equals(0));
      // print('We check if the ListView can be scrollable');
      // print('Manually scrolling 200 pixels down');
      // await tester.drag(find.byType(ListView), const Offset(0.0, -200.0));
      // print('Flush the widget tree');
      // await tester.pump();
      // var contactElement = tester.widget<ContactMessagePreview>(
      //     find.byType(ContactMessagePreview).first);
      // expect(contactElement, findsOneWidget);
    });
  });
}
