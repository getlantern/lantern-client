import 'package:lantern/app.dart';
import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/router/router.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:lantern/features/replica/models/replica_model.dart';
import 'package:lantern/features/tray/tray_container.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:lantern/features/window/window_container.dart';
import 'package:patrol/patrol.dart';

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

  tearDown(
    () {
      clearInteractions(mockSessionModel);
      clearInteractions(mockBuildContext);
      clearInteractions(mockMessagingModel);
      clearInteractions(mockReplicaModel);
      clearInteractions(mockVpnModel);
      clearInteractions(mockEventManager);
      clearInteractions(mockVPNChangeNotifier);
      clearInteractions(mockBottomBarChangeNotifier);
      clearInteractions(mockInternetStatusProvider);
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
      patrolWidgetTest('app start with proper setting', ($) async {
        mockStartApp(
            mockSessionModel: mockSessionModel,
            mockBottomBarChangeNotifier: mockBottomBarChangeNotifier,
            mockVPNChangeNotifier: mockVPNChangeNotifier,
            mockMessagingModel: mockMessagingModel,
            mockEventManager: mockEventManager,
            mockBuildContext: mockBuildContext,
            mockVpnModel: mockVpnModel);

        await $.pumpWidget(const LanternApp());

        final app = $.tester.widget<MaterialApp>(find.byType(MaterialApp));
        final theme = app.theme!;

        expect(app.locale, const Locale('en', 'US'));
        expect(theme.useMaterial3, false);
        expect(theme.brightness, Brightness.light);
        expect(app.title, 'app_name'.i18n);
        expect($(I18n), findsOneWidget);
        expect($(ScaffoldMessenger), findsOneWidget);
        expect($(GlobalLoaderOverlay), findsOneWidget);
      }, variant: TargetPlatformVariant.all());

      patrolWidgetTest(
        'Providers are correctly initialized',
        ($) async {
          mockStartApp(
              mockSessionModel: mockSessionModel,
              mockBottomBarChangeNotifier: mockBottomBarChangeNotifier,
              mockVPNChangeNotifier: mockVPNChangeNotifier,
              mockMessagingModel: mockMessagingModel,
              mockEventManager: mockEventManager,
              mockBuildContext: mockBuildContext,
              mockVpnModel: mockVpnModel);

          await $.pumpWidget(const LanternApp());

          final bottomBarProvider = Provider.of<BottomBarChangeNotifier>(
              $.tester.element(find.byType(MaterialApp)),
              listen: false);
          expect(bottomBarProvider, isNotNull);

          final vpnProvider = Provider.of<VPNChangeNotifier>(
              $.tester.element(find.byType(MaterialApp)),
              listen: false);

          expect(vpnProvider, isNotNull);

          final internetStatusProvider = Provider.of<InternetStatusProvider>(
              $.tester.element(find.byType(MaterialApp)),
              listen: false);
          expect(internetStatusProvider, isNotNull);
        },
        variant: TargetPlatformVariant.all(),
      );

      patrolWidgetTest('Desktop-specific widgets are used on desktop platforms',
          ($) async {
        mockStartApp(
            mockSessionModel: mockSessionModel,
            mockBottomBarChangeNotifier: mockBottomBarChangeNotifier,
            mockVPNChangeNotifier: mockVPNChangeNotifier,
            mockMessagingModel: mockMessagingModel,
            mockEventManager: mockEventManager,
            mockBuildContext: mockBuildContext,
            mockVpnModel: mockVpnModel);

        await $.pumpWidget(const LanternApp());

        // Verify that WindowContainer and TrayContainer are used
        if (isMobile()) {
          expect($(WindowContainer), findsNothing);
          expect($(TrayContainer), findsNothing);
        } else {
          expect($(WindowContainer), findsOneWidget);
          expect($(TrayContainer), findsOneWidget);
        }
      }, variant: TargetPlatformVariant.all(excluding: {TargetPlatform.fuchsia}));
    },
  );
}
