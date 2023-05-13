import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lantern/app.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/custom_bottom_bar.dart';
import 'package:lantern/main.dart' as app;
import 'package:lantern/vpn/vpn_tab.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('VPN Test', () {
    testWidgets('Should start the LanternApp ', (widgetTester) async {
      await widgetTester.runAsync(() async {
        await app.main();
        await widgetTester.pumpAndSettle();
      });
      final listViewFinder = find.byType(LanternApp);

      expect(listViewFinder, findsOneWidget);
    });

    testWidgets('Should render home page and start with VPN tab selected ',
        (widgetTester) async {
      // Pump the LanternApp widget
      await widgetTester.pumpWidget(LanternApp());

      // Wait for the app to settle
      await widgetTester.pumpAndSettle();

      final customBottomBar = find.byType(CustomBottomBar);
      final vpnTap = find.byType(VPNTab);

      //Wait until the app is show bottom bar
      await waitFor(widgetTester, customBottomBar);

      // Verify that the CustomBottomBar widget is present
      expect(customBottomBar, findsOneWidget);
      // Verify that the VPN tap widget is present
      expect(vpnTap, findsOneWidget);
    });

    testWidgets('Should start VPN when user switches On', (widgetTester) async {
      await widgetTester.pumpWidget(LanternApp());

      // Wait for the app to settle
      await widgetTester.pumpAndSettle();
      final vpnSwitchFinder = find.byType(FlutterSwitch);

      //Wait until the vpn widget shows up
      await waitFor(widgetTester, vpnSwitchFinder);
      final vpnSwitch = widgetTester.widget<FlutterSwitch>(vpnSwitchFinder);

      // There should be only one switch
      expect(vpnSwitchFinder, findsOneWidget);
      expect(vpnSwitch.value, false);

      //Tap on switch
      await widgetTester.tap(vpnSwitchFinder);
      await widgetTester.pumpAndSettle();

      final finalSwitchState =
          widgetTester.widget<FlutterSwitch>(vpnSwitchFinder).value;

      // Verify that the switch state has changed
      expect(finalSwitchState, true);
    });
  });
}

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = tester.binding.clock.now().add(timeout);
  do {
    if (tester.binding.clock.now().isAfter(end)) {
      throw Exception('Timed out waiting for $finder');
    }
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 100));
  } while (finder.evaluate().isEmpty);
}

///Old Test code
// Future<void> main() async {
//   await runTest(
//     (driver) async {
//       await driver.openTab('VPN');
//       await driver.tapType('FlutterSwitch');
//     },
//   );
// }
