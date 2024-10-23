// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:lantern/app_startup_flow_test.dart';
// import 'package:lantern/core/utils/common.dart';
// import 'package:lantern/features/home/home.dart';
// import 'package:lantern/features/messaging/messaging_model.dart';
// import 'package:mockito/mockito.dart';
//
// class MockNavigationObserver extends Mock implements NavigatorObserver {}
//
// void main() {
//   final mockObserver = MockNavigationObserver();
//
//   setUp(() {
//     reset(mockObserver);
//   });
//
//   group(
//     'Widget startup',
//     () {
//       Future<void> _buildHomeScreen(WidgetTester tester) async {
//         await tester.pumpWidget(
//           MultiProvider(
//             providers: [
//               Provider(create: (context) => MessagingModel()),
//               Provider(create: (context) => VpnModel()),
//               Provider(create: (context) => AudioPlayer()),
//               Provider(create: (context) => SessionModel()),
//               Provider(
//                 create: (context) => EventManager('lantern_event_channel'),
//               ),
//               Provider(
//                 create: (context) =>
//                     const MethodChannel('lantern_method_channel'),
//               ),
//             ],
//             child: FutureBuilder(
//               future: Localization.ensureInitialized(),
//               builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
//                 return GlobalLoaderOverlay(
//                   child: I18n(
//                     initialLocale: const Locale('en', 'US'),
//                     child: MaterialApp.router(
//                       debugShowCheckedModeBanner: false,
//                       title: 'Lantern Messenger',
//                       localizationsDelegates: [
//                         GlobalMaterialLocalizations.delegate,
//                         GlobalWidgetsLocalizations.delegate,
//                         GlobalCupertinoLocalizations.delegate,
//                       ],
//                       routeInformationParser: globalRouter.defaultRouteParser(),
//                       routerDelegate: globalRouter.delegate(
//                         navigatorObservers: () => [
//                           mockObserver,
//                         ],
//                       ),
//                       // TODO <08-08-22, kalli> Confirm we can use BotToast
//                       //builder: BotToastInit(),
//                       supportedLocales: [
//                         const Locale('ar', 'EG'),
//                         const Locale('fr', 'FR'),
//                         const Locale('en', 'US'),
//                         const Locale('fa', 'IR'),
//                         const Locale('th', 'TH'),
//                         const Locale('ms', 'MY'),
//                         const Locale('ru', 'RU'),
//                         const Locale('ur', 'IN'),
//                         const Locale('zh', 'CN'),
//                         const Locale('zh', 'HK'),
//                         const Locale('es', 'ES'),
//                         const Locale('tr', 'TR'),
//                         const Locale('vi', 'VN'),
//                         const Locale('my', 'MM'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//         await tester.pumpAndSettle();
//         expect(find.byType(HomePage), findsOneWidget);
//       }
//
//       testWidgets('Should display home page', (WidgetTester tester) async {
//         await _buildHomeScreen(tester);
//       });
//     },
//   );
// }
