import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/home/home.dart';

import '../../utils/test_common.dart';
import '../../utils/widgets.dart';

void main() {
  late MockSessionModel mockSessionModel;
  late MockBuildContext mockBuildContext;

  setUpAll(
    () {
      sl.registerLazySingleton(() => SessionModel());
      sl.registerLazySingleton(() => VpnModel());
      mockSessionModel = MockSessionModel();
      mockBuildContext = MockBuildContext();
    },
  );

  tearDownAll(
    () {
      sl.reset();
    },
  );

  group(
    "Home widget render properly for mobile",
    () {
      testWidgets(
        "Home widget started",
        (widgetTester) async {
          final homeWidget = MultiProvider(providers: [
            ChangeNotifierProvider(
                create: (context) => BottomBarChangeNotifier()),
            // ChangeNotifierProvider(create: (context) => VPNChangeNotifier()),
            // ChangeNotifierProvider(create: (context) => InternetStatusProvider())
          ], child: wrapWithMaterialApp(const HomePage()));

          /// Now stub all daa widgets

          when(mockSessionModel.acceptedTermsVersion(intEmptyBuilder))
              .thenAnswer(
            (invocation) {
              final builder = invocation.namedArguments[const Symbol('builder')]
                  as ValueWidgetBuilder<int>;
              return builder(mockBuildContext, 1, null);
            },
          );

          when(mockSessionModel.developmentMode(boolEmptyBuilder)).thenAnswer(
            (realInvocation) {
              return boolEmptyBuilder(mockBuildContext, true, null);
            },
          );

          when(mockSessionModel.isAuthEnabled).thenAnswer(
            (realInvocation) {
              return ValueNotifier(false);
            },
          );



          widgetTester.pumpWidget(homeWidget);
        },
      );
    },
  );
}
