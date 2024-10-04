// import 'package:lantern/common/ui/custom/internet_checker.dart';
// import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
// import 'package:lantern/features/home/home.dart';
// import 'package:lantern/features/vpn/vpn_notifier.dart';
//
// import 'utils/test_common.dart';
//
//
//
// final emptyBuilder = (context, value, child) => Container();
//
// void main() {
//
//   // Mocks the providers also
//   group(
//     "Home widget test for mobile devices",
//     () {
//       testWidgets("home widget look okay", (widgetTester) async {
//         when(mockSessionModel.acceptedTermsVersion((emptyBuilder))).thenAnswer(
//           (invocation) {
//             final builder = invocation.namedArguments[const Symbol('builder')]
//                 as ValueWidgetBuilder<int>;
//             return builder(mockBuildContext, 1, null);
//           },
//         );
//
//         final myApp = MaterialApp(
//           home: MultiProvider(
//             providers: [
//               ChangeNotifierProvider(
//                   create: (context) => BottomBarChangeNotifier()),
//               ChangeNotifierProvider(create: (context) => VPNChangeNotifier()),
//               ChangeNotifierProvider(
//                   create: (context) => InternetStatusProvider())
//             ],
//             child: HomePage(),
//           ),
//         );
//
//         await widgetTester.pumpWidget(myApp);
//         // await widgetTester.pumpAndSettle();
//
//         expect(find.byType(BottomAppBar), findsOneWidget);
//       }, variant: TargetPlatformVariant.only(TargetPlatform.android));
//     },
//   );
// }
