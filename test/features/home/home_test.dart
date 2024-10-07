import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/home/home.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';

import '../../utils/test_common.dart';
import '../../utils/widgets.dart';

// https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k
void main() {
  late MockSessionModel mockSessionModel;
  late MockBuildContext mockBuildContext;
  late MockMessagingModel mockMessagingModel;

  setUpAll(
    () {
      mockSessionModel = MockSessionModel();
      mockBuildContext = MockBuildContext();
      mockMessagingModel = MockMessagingModel();

      sl.registerLazySingleton<SessionModel>(() => mockSessionModel);
      sl.registerLazySingleton<MessagingModel>(() => mockMessagingModel);

      sl.registerLazySingleton(() => VpnModel());
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
        "Home widget started ",
        (widgetTester) async {
          final homeWidget = MultiProvider(providers: [
            ChangeNotifierProvider(
                create: (context) => BottomBarChangeNotifier()),
            ChangeNotifierProvider(create: (context) => VPNChangeNotifier()),
            ChangeNotifierProvider(
                create: (context) => InternetStatusProvider())
          ], child: wrapWithMaterialApp(const HomePage()));

          /// Now stub all daa widgets

          // / Use Mockito's `any` matcher to match the argument passed to `acceptedTermsVersion`
          when(mockSessionModel.acceptedTermsVersion(any))
              .thenAnswer((invocation) {
            final builder =
                invocation.positionalArguments[0] as ValueWidgetBuilder<int>;
            return builder(
                mockBuildContext, 0, null);
          });

          when(mockSessionModel.developmentMode(any)).thenAnswer(
            (invocation) {
              final builder =
              invocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
              return builder(
                  mockBuildContext, true, null);
            },
          );



          when(mockSessionModel.isTestPlayVersion).thenAnswer((realInvocation) => ValueNotifier(false));
          when(mockSessionModel.isStoreVersion).thenAnswer((realInvocation) => ValueNotifier(false));
          when(mockSessionModel.isAuthEnabled).thenAnswer((realInvocation) => ValueNotifier(false));


          when(mockMessagingModel.getOnBoardingStatus(any))
              .thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );

          when(mockSessionModel.chatEnabled(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );
          //
          when(mockSessionModel.replicaAddr(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0] as ValueWidgetBuilder<String>;
              return builder(mockBuildContext, "", null);
            },
          );

          when(mockSessionModel.proUser(any)).thenAnswer(
            (realInvocation) {
              return boolEmptyBuilder(mockBuildContext, false, null);
            },
          );

          await widgetTester.pumpWidget(homeWidget);

          expect(find.byType(BottomNavigationBar), findsOneWidget);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );
    },
  );
}
