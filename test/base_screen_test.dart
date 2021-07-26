import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/app.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

void main() {
  group(
    'Widget startup',
    () {
      // Create a LanternApp widget test.

      testWidgets(
        'Test coverage for base_screen.dart',
        (WidgetTester tester) async {
          print('Load the root widget without catcher');
          await tester.pumpWidget(LanternApp());

          var baseScreen = find.byType(BaseScreen);
          print('Check for the BaseScreen to be loaded correctly');
          expect(baseScreen, findsOneWidget);

          var customAppbar = find.byType(CustomAppBar);
          print('Check for the CustomAppBar to be loaded correctly');
          expect(customAppbar, findsOneWidget);

          await tester.pump(const Duration(seconds: 5));

          var homePage = find.byType(HomePage);
          print('Check for the HomePage to be loaded correctly');
          expect(homePage, findsOneWidget);

          // await tester.pumpWidget(
          //   LanternApp(),
          // );
          // find.byWidget(
          //   LoaderOverlay(
          //     child: HomePage(
          //       '/',
          //       {},
          //     ),
          //   ),
          // );
          // await tester.pump();
          // print('Check for the LoaderOverlay being displayed');
          // expect(find.byType(LoaderOverlay), findsOneWidget);
          // await tester.pump(const Duration(seconds: 5));
          // print('Check if homepage is visible after loader');
          // expect(find.byType(HomePage), findsOneWidget);
        },
      );

      // testWidgets(
      //   'Settings Test',
      //   (WidgetTester tester) async {
      //     print('Mock a fake materialApp to generate a fake context');
      //     await tester.pumpWidget(
      //       MultiProvider(
      //         providers: [
      //           Provider(create: (context) => VpnModel()),
      //           Provider(create: (context) => SessionModel()),
      //           Provider(
      //               create: (context) => EventManager('lantern_event_channel')),
      //           Provider(
      //               create: (context) =>
      //                   const MethodChannel('lantern_method_channel')),
      //         ],
      //         child: MaterialApp(
      //           home: Material(
      //             child: Container(),
      //           ),
      //         ),
      //       ),
      //     );
      //     print('Set the fake context into a final variable');
      //     final BuildContext context = tester.element(find.byType(Container));
      //     var sessionModel = Provider.of<SessionModel>(context, listen: false);
      //     print('Load the Settings UI');
      //     var proxy = SettingsItem(
      //       icon: ImagePaths.key_icon,
      //       title: 'proxy_all',
      //       child: sessionModel
      //           .proxyAll((BuildContext context, bool proxyAll, Widget? child) {
      //         return FlutterSwitch(
      //           width: 44.0,
      //           height: 24.0,
      //           valueFontSize: 12.0,
      //           padding: 2,
      //           toggleSize: 18.0,
      //           value: proxyAll,
      //           activeColor: indicatorGreen,
      //           inactiveColor: offSwitchColor,
      //           onToggle: (bool newValue) async {
      //             await sessionModel.setProxyAll(newValue);
      //           },
      //         );
      //       }),
      //     );
      //     await tester.pump();
      //     print('Check for the widget be false');
      //     var liste =
      //         (proxy.child as SubscribedSingleValueBuilder).valueListenable;
      //     print("liste: ${liste.value}");
      //   },
      // );
    },
  );
}
