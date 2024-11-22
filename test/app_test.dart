import 'package:lantern/app.dart';
import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/router/router.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:lantern/features/replica/models/replica_model.dart';
import 'package:lantern/features/tray/tray_container.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:lantern/features/vpn/vpn_status.dart';
import 'package:lantern/features/window/window_container.dart';

import 'utils/test_common.dart';

void main() {
  late MockSessionModel mockSessionModel;
  late MockBuildContext mockBuildContext;
  late MockMessagingModel mockMessagingModel;
  late MockReplicaModel mockReplicaModel;
  late MockVpnModel mockVpnModel;
  late MockBottomBarChangeNotifier mockBottomBarChangeNotifier;
  late MockInternetStatusProvider mockInternetStatusProvider;
  late MockEventManager mockEventManager;
  late MockVPNChangeNotifier mockVPNChangeNotifier;

  setUpAll(
    () {
      mockSessionModel = MockSessionModel();
      mockBuildContext = MockBuildContext();
      mockMessagingModel = MockMessagingModel();

      mockReplicaModel = MockReplicaModel();
      mockVpnModel = MockVpnModel();
      mockEventManager = MockEventManager();

      mockVPNChangeNotifier = MockVPNChangeNotifier();
      mockBottomBarChangeNotifier = MockBottomBarChangeNotifier();
      mockInternetStatusProvider = MockInternetStatusProvider();
      // Injection models
      sl.registerLazySingleton<SessionModel>(() => mockSessionModel);
      sl.registerLazySingleton<MessagingModel>(() => mockMessagingModel);
      sl.registerLazySingleton<ReplicaModel>(() => mockReplicaModel);
      sl.registerLazySingleton<VpnModel>(() => mockVpnModel);
      sl.registerLazySingleton<AppRouter>(() => AppRouter());
      sl.registerLazySingleton<BottomBarChangeNotifier>(
          () => mockBottomBarChangeNotifier);
      sl.registerLazySingleton<VPNChangeNotifier>(() => mockVPNChangeNotifier);
      sl.registerLazySingleton<InternetStatusProvider>(
          () => mockInternetStatusProvider);
    },
  );

  tearDownAll(
    () {
      sl.reset();
    },
  );

  group(
    'app widget',
    () {
      testWidgets(
        'Providers are correctly initialized',
        (WidgetTester tester) async {
          tester.view.devicePixelRatio = 2.0;
          tester.platformDispatcher.localesTestValue = <Locale>[
            const Locale('en-us'),
            const Locale('ar-jo')
          ];
          tester.platformDispatcher.localeTestValue = const Locale('en-us');

          when(mockSessionModel.proxyAvailable).thenReturn(ValueNotifier(true));
          when(mockSessionModel.pathValueNotifier(any, false))
              .thenReturn(ValueNotifier(true));

          when(mockSessionModel.language(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
                  as ValueWidgetBuilder<String>;
              return builder(mockBuildContext, 'en_in', null);
            },
          );

          when(mockSessionModel.acceptedTermsVersion(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
                  as ValueWidgetBuilder<int>;
              return builder(mockBuildContext, 0, null);
            },
          );

          when(mockSessionModel.chatEnabled(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
                  as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );

          when(mockSessionModel.developmentMode(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
                  as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );

          await tester.pumpWidget(const LanternApp());

          final bottomBarProvider = Provider.of<BottomBarChangeNotifier>(
              tester.element(find.byType(MaterialApp)),
              listen: false);
          expect(bottomBarProvider, isNotNull);

          final vpnProvider = Provider.of<VPNChangeNotifier>(
              tester.element(find.byType(MaterialApp)),
              listen: false);

          expect(vpnProvider, isNotNull);

          final internetStatusProvider = Provider.of<InternetStatusProvider>(
              tester.element(find.byType(MaterialApp)),
              listen: false);
          expect(internetStatusProvider, isNotNull);
        },
      );

      testWidgets('Desktop-specific widgets are used on desktop platforms',
          (WidgetTester tester) async {
        when(mockBottomBarChangeNotifier.currentIndex).thenReturn(TAB_VPN);
        when(mockVPNChangeNotifier.vpnStatus).thenReturn(ValueNotifier(TestVPNStatus.disconnected.value));

        when(mockSessionModel.proxyAvailable).thenReturn(ValueNotifier(true));
        when(mockSessionModel.isTestPlayVersion)
            .thenReturn(ValueNotifier(false));
        when(mockSessionModel.isStoreVersion).thenReturn(ValueNotifier(false));
        when(mockSessionModel.isAuthEnabled).thenReturn(ValueNotifier(false));

        when(mockSessionModel.language(any)).thenAnswer(
          (realInvocation) {
            final builder = realInvocation.positionalArguments[0]
                as ValueWidgetBuilder<String>;
            return builder(mockBuildContext, 'en_us', null);
          },
        );

        when(mockSessionModel.acceptedTermsVersion(any)).thenAnswer(
          (realInvocation) {
            final builder = realInvocation.positionalArguments[0]
                as ValueWidgetBuilder<int>;
            return builder(mockBuildContext, 0, null);
          },
        );

        when(mockSessionModel.proUser(any)).thenAnswer(
          (realInvocation) {
            final builder = realInvocation.positionalArguments[0]
                as ValueWidgetBuilder<bool>;
            return builder(mockBuildContext, false, null);
          },
        );

        when(mockSessionModel.developmentMode(any)).thenAnswer(
          (realInvocation) {
            final builder = realInvocation.positionalArguments[0]
                as ValueWidgetBuilder<bool>;
            return builder(mockBuildContext, false, null);
          },
        );

        when(mockSessionModel.chatEnabled(any)).thenAnswer(
          (realInvocation) {
            final builder = realInvocation.positionalArguments[0]
                as ValueWidgetBuilder<bool>;
            return builder(mockBuildContext, false, null);
          },
        );

        when(mockSessionModel.replicaAddr(any)).thenAnswer(
          (realInvocation) {
            final builder = realInvocation.positionalArguments[0]
                as ValueWidgetBuilder<String>;
            return builder(mockBuildContext, '', null);
          },
        );

        when(mockMessagingModel.getOnBoardingStatus(any)).thenAnswer(
          (realInvocation) {
            final builder = realInvocation.positionalArguments[0]
                as ValueWidgetBuilder<bool?>;
            return builder(mockBuildContext, null, null);
          },
        );

        stubVpnModel(
            mockVpnModel: mockVpnModel, mockBuildContext: mockBuildContext);

        await tester.pumpWidget(const LanternApp());

        // Verify that WindowContainer and TrayContainer are used
        expect(find.byType(WindowContainer), findsOneWidget);
        expect(find.byType(TrayContainer), findsOneWidget);
      }, variant: TargetPlatformVariant.desktop());
    },
  );
}
