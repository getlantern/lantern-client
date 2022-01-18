import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/home.dart';
import 'package:lantern/messaging/chats.dart';

import 'action/navigation_action_test.dart';
import 'enums/screens_test.dart';

export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:i18n_extension/i18n_widget.dart';
export 'package:lantern/i18n/i18n.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  group('Messaging Page Integration Test', () {
    testWidgets('Initial page should be HomePage', (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MAIN);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Check if MessagesPages is loaded',
        (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      expect(find.byType(Chats), findsOneWidget);
    });

    testWidgets('Check for components loaded correctly on MessagesPages AppBar',
        (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      expect(
        find.byType(AppBar),
        findsOneWidget,
        reason: 'Search for a CustomAppBar',
      );
      expect(find.widgetWithText(AppBar, 'Messages'), findsOneWidget);
      // TODO: This is outdated, needs fix
      expect(
        find.byIcon(Icons.search),
        findsOneWidget,
        reason: 'Search should be displayed',
      );
      // TODO: This is outdated, needs fix
      expect(
        find.byIcon(Icons.qr_code),
        findsOneWidget,
        reason: 'QR should be displayed',
      );
    });

    testWidgets('Check for BottomBar being loaded with all their components',
        (WidgetTester tester) async {
      await GoTo.navigateTo(tester, to: SCREENS.MESSAGES);
      expect(
        find.byType(AutoTabsScaffold),
        findsOneWidget,
        reason: 'Check if the AutoTabsScaffold is already on stage',
      );
      var autoTabsScaffold =
          tester.widget<AutoTabsScaffold>(find.byType(AutoTabsScaffold));
      expect(
        autoTabsScaffold.routes,
        isNotEmpty,
        reason: 'The available routes should not be empty',
      );
      expect(
        autoTabsScaffold.routes.length,
        4,
        reason: 'The available routes should be 4',
      );
      expect(
        find.byType(CustomBottomBar),
        findsOneWidget,
        reason: 'Check if the CustomBottomBar is displayed',
      );
      var cb = tester.widget<CustomBottomBar>(find.byType(CustomBottomBar));
      // TODO: fix
      // expect(
      //   cb.index,
      //   0,
      //   reason: 'Check if the current page is 0, which correspond to Messaging',
      // );
    });
  });
}
