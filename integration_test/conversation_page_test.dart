import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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
      await tester.tap(find.widgetWithText(ContactMessagePreview, 'me'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 20));
    });
  });
}
