import 'package:lantern/app.dart';
import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:lantern/features/replica/models/replica_model.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';

import 'utils/test_common.dart';

void main() {
  late MockSessionModel mockSessionModel;
  late MockBuildContext mockBuildContext;
  late MockMessagingModel mockMessagingModel;
  late MockReplicaModel mockReplicaModel;
  late MockVpnModel mockVpnModel;

  setUp(
    () {
      mockSessionModel = MockSessionModel();
      mockBuildContext = MockBuildContext();
      mockMessagingModel = MockMessagingModel();

      mockReplicaModel = MockReplicaModel();
      mockVpnModel = MockVpnModel();

      // Injection models
      sl.registerLazySingleton<SessionModel>(() => mockSessionModel);
      sl.registerLazySingleton<MessagingModel>(() => mockMessagingModel);
      sl.registerLazySingleton<ReplicaModel>(() => mockReplicaModel);
      sl.registerLazySingleton<VpnModel>(() => mockVpnModel);
    },
  );

  tearDown(
    () {
      sl.reset();
    },
  );

  // testWidgets(
  //   'Providers are correctly initialized',
  //   (WidgetTester tester) async {
  //     tester.view.devicePixelRatio = 2.0;
  //     tester.platformDispatcher.localesTestValue = <Locale>[const Locale('en-us'), const Locale('ar-jo')];
  //     tester.platformDispatcher.localeTestValue = const Locale('en-us');
  //
  //
  //     when(mockSessionModel.proxyAvailable).thenReturn(ValueNotifier(true));
  //
  //     when(mockSessionModel.language(any)).thenAnswer(
  //       (realInvocation) {
  //         final builder = realInvocation.positionalArguments[0]
  //             as ValueWidgetBuilder<String>;
  //         return builder(mockBuildContext, 'en_in', null);
  //       },
  //     );
  //
  //     when(mockSessionModel.acceptedTermsVersion(any)).thenAnswer(
  //           (realInvocation) {
  //         final builder = realInvocation.positionalArguments[0]
  //         as ValueWidgetBuilder<int>;
  //         return builder(mockBuildContext, 0, null);
  //       },
  //     );
  //
  //     when(mockSessionModel.developmentMode(any)).thenAnswer(
  //           (realInvocation) {
  //         final builder = realInvocation.positionalArguments[0]
  //         as ValueWidgetBuilder<bool>;
  //         return builder(mockBuildContext, false, null);
  //       },
  //     );
  //
  //     await tester.pumpWidget(const LanternApp());
  //     // await tester.pumpAndSettle();
  //
  //     final bottomBarProvider = Provider.of<BottomBarChangeNotifier>(
  //         tester.element(find.byType(MaterialApp)),listen: false);
  //     expect(bottomBarProvider, isNotNull);
  //
  //     final vpnProvider = Provider.of<VPNChangeNotifier>(
  //         tester.element(find.byType(MaterialApp)),listen: false);
  //
  //     expect(vpnProvider, isNotNull);
  //
  //     final internetStatusProvider = Provider.of<InternetStatusProvider>(
  //         tester.element(find.byType(MaterialApp)));
  //     expect(internetStatusProvider, isNotNull);
  //   },
  // );
  //
  // testWidgets('App applies correct localization and language',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(const LanternApp());
  //
  //   await tester.pumpAndSettle();
  //   expect(find.text('app_name'.i18n), findsOneWidget);
  //
  //   // Change the language and verify the locale change is applied
  //   final sessionModel =
  //       Provider.of<SessionModel>(tester.element(find.byType(MaterialApp)));
  //   sessionModel.setLanguage('fr');
  //   await tester.pumpAndSettle();
  //
  //   expect(Localization.locale, 'fr');
  // });
}
