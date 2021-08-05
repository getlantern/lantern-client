import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/messaging/messages.dart';
import 'package:lantern/ui/app.dart';
import 'package:lantern/ui/home.dart';
import 'package:lantern/ui/widgets/custom_bottom_bar.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:i18n_extension/i18n_widget.dart';
export 'package:lantern/i18n/i18n.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  group('Messaging Page Integration Test', () {
    testWidgets('Initial page should be HomePage', (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      print(
          'We use 2 pump and settle due to the elevated number of process that must been done on Android before starting flutter.');
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Check if MessagesPages is loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      print(
          'We use 2 pump and settle due to the elevated number of process that must been done on Android before starting flutter.');
      await tester.pumpAndSettle();
      expect(find.byType(Messages), findsOneWidget);
    });

    testWidgets('Check for components loaded correctly on MessagesPages AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      print(
          'We use 2 pump and settle due to the elevated number of process that must been done on Android before starting flutter.');
      await tester.pumpAndSettle();
      print('Search for a CustomAppBar');
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Messages'), findsOneWidget);
      print('Search and QR should be displayed');
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.qr_code), findsOneWidget);
    });

    testWidgets('Check for BottomBar being loaded with all their components',
        (WidgetTester tester) async {
      await tester.pumpWidget(LanternApp());
      await tester.pumpAndSettle();
      print(
          'We use 2 pump and settle due to the elevated number of process that must been done on Android before starting flutter.');
      await tester.pumpAndSettle();
      print('Check if the AutoTabsScaffold is already on stage');
      expect(find.byType(AutoTabsScaffold), findsOneWidget);
      var autoTabsScaffold =
          tester.widget<AutoTabsScaffold>(find.byType(AutoTabsScaffold));
      print('The available routes should not be empty');
      expect(autoTabsScaffold.routes, isNotEmpty);
      print('The available routes should be 4');
      expect(autoTabsScaffold.routes.length, 4);

      print('Check if the CustomBottomBar is displayed');
      expect(find.byType(CustomBottomBar), findsOneWidget);
      var cb = tester.widget<CustomBottomBar>(find.byType(CustomBottomBar));
      print('Check if the current page is 0, which correspond to Messaging');
      expect(cb.index, 0);
    });
  });
}
