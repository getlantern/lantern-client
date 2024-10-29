import 'package:lantern/app.dart';
import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/router/router.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';

import '../../../test/utils/test_common.dart';
import '../../utils/test_utils.dart';

/// This is a mock test file for the home page flow.
/// The file exists to mock data for certain scenarios.
/// This ensures the homepage works as expected.
/// Examples include:
/// 1. Showing the privacy policy if the user is using the app from the Play Store.
/// 2. Showing a local plan if the user is using the app from the App Store.
/// Using mocks, we can test these scenarios effectively.
void main() {
  late MockSessionModel mockSessionModel;
  late MockBuildContext mockBuildContext;
  late MockMessagingModel mockMessagingModel;
  late MockBottomBarChangeNotifier mockBottomBarChangeNotifier;
  late MockVPNChangeNotifier mockVPNChangeNotifier;
  late MockInternetStatusProvider mockInternetStatusProvider;
  late MockReplicaModel mockReplicaModel;
  late MockVpnModel mockVpnModel;
  late MockEventManager mockEventManager;
  late ValueNotifier<bool> proxyNotifier;

  setUpAll(
    () async {
      await Localization.ensureInitialized();

      mockSessionModel = MockSessionModel();
      mockBuildContext = MockBuildContext();
      mockMessagingModel = MockMessagingModel();
      mockBottomBarChangeNotifier = MockBottomBarChangeNotifier();
      mockVPNChangeNotifier = MockVPNChangeNotifier();
      mockInternetStatusProvider = MockInternetStatusProvider();
      mockReplicaModel = MockReplicaModel();
      mockVpnModel = MockVpnModel();
      mockEventManager = MockEventManager();

      // Injection models
      sl.registerLazySingleton<SessionModel>(() => mockSessionModel);
      sl.registerLazySingleton<MessagingModel>(() => mockMessagingModel);
      sl.registerLazySingleton<ReplicaModel>(() => mockReplicaModel);
      sl.registerLazySingleton<VpnModel>(() => mockVpnModel);
      sl.registerLazySingleton<AppRouter>(() => AppRouter());

      // mock the providers
      mockBottomBarChangeNotifier = MockBottomBarChangeNotifier();
      mockVPNChangeNotifier = MockVPNChangeNotifier();
      mockInternetStatusProvider = MockInternetStatusProvider();

      // Injection models
      sl.registerLazySingleton<BottomBarChangeNotifier>(
          () => mockBottomBarChangeNotifier);
      sl.registerLazySingleton<VPNChangeNotifier>(() => mockVPNChangeNotifier);
      sl.registerLazySingleton<InternetStatusProvider>(
          () => mockInternetStatusProvider);
      proxyNotifier = ValueNotifier<bool>(true);
    },
  );

  tearDown(
    () async {
      clearInteractions(mockSessionModel);
      clearInteractions(mockReplicaModel);
      clearInteractions(mockVpnModel);
      clearInteractions(mockMessagingModel);
      clearInteractions(mockBottomBarChangeNotifier);
      clearInteractions(mockVPNChangeNotifier);
      clearInteractions(mockInternetStatusProvider);

    },
  );

  tearDownAll(
    () async {
      await sl.reset();
    },
  );

  patrolWidgetTest(
    'home widget show privacy policy',
    skip: isDesktop(),
    ($) async {
      when(mockBottomBarChangeNotifier.currentIndex).thenReturn(TAB_VPN);

      /// Stub session model
      when(mockSessionModel.proxyAvailable).thenReturn(proxyNotifier);
      when(mockSessionModel.pathValueNotifier(any, false))
          .thenReturn(ValueNotifier(true));

      when(mockSessionModel.language(any)).thenAnswer(
        (invocation) {

          final builder =
              invocation.positionalArguments[0] as ValueWidgetBuilder<String>;
          return builder(mockBuildContext, 'en_us', null);
        },
      );

      when(mockSessionModel.acceptedTermsVersion(any)).thenAnswer((invocation) {
        final builder =
            invocation.positionalArguments[0] as ValueWidgetBuilder<int>;
        return builder(mockBuildContext, 0, null);
      });

      when(mockSessionModel.developmentMode(any)).thenAnswer(
        (invocation) {
          final builder =
              invocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
          return builder(mockBuildContext, true, null);
        },
      );

      when(mockSessionModel.isTestPlayVersion)
          .thenAnswer((realInvocation) => ValueNotifier(false));
      when(mockSessionModel.isStoreVersion).thenAnswer((realInvocation) {
        return ValueNotifier(true);
      });
      when(mockSessionModel.isAuthEnabled)
          .thenAnswer((realInvocation) => ValueNotifier(false));

      when(mockSessionModel.chatEnabled(any)).thenAnswer(
        (realInvocation) {
          final builder =
              realInvocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
          return builder(mockBuildContext, false, null);
        },
      );

      when(mockSessionModel.replicaAddr(any)).thenAnswer(
        (realInvocation) {
          final builder = realInvocation.positionalArguments[0]
              as ValueWidgetBuilder<String>;
          return builder(mockBuildContext, "", null);
        },
      );

      when(mockSessionModel.proUser(any)).thenAnswer(
        (realInvocation) {
          return boolEmptyBuilder(mockBuildContext, false, null);
        },
      );

      when(mockSessionModel.eventManager).thenReturn(mockEventManager);
      when(mockEventManager.subscribe(any, any)).thenAnswer((realInvocation) {
        final event = realInvocation.positionalArguments[0] as Event;
        final onNewEvent =
            realInvocation.positionalArguments[1] as void Function(Event, Map);
        return () {
          onNewEvent(event, {});
        };
      });

      when(mockSessionModel.acceptedTermsVersion(any)).thenAnswer(
        (realInvocation) {
          final builder =
              realInvocation.positionalArguments[0] as ValueWidgetBuilder<int>;
          return builder(mockBuildContext, 0, null);
        },
      );

      await $.pumpWidget(const LanternApp());
      await $.pumpAndSettle();

      await $.pump(const Duration(seconds: 5));
      await $(FullScreenDialog).waitUntilVisible(timeout: const Duration(seconds: 20));

      expect($('privacy_disclosure_accept'.i18n.toUpperCase()), findsOneWidget);
      expect($(BottomNavigationBar), findsNothing);
    },
  );

  patrolWidgetTest(
    'home widget auth enable show first time visit screen',
    ($) async {
      if(isDesktop()){
        when(mockVPNChangeNotifier.vpnStatus).thenReturn(ValueNotifier(TestVPNStatus.connected.value));
      }
      when(mockBottomBarChangeNotifier.currentIndex).thenReturn(TAB_VPN);
      when(mockVPNChangeNotifier.isFlashlightInitialized).thenReturn(true);

      /// Stub session model
      when(mockSessionModel.proxyAvailable).thenReturn(ValueNotifier(true));

      when(mockSessionModel.pathValueNotifier(any, false))
          .thenReturn(ValueNotifier(true));

      when(mockSessionModel.language(any)).thenAnswer(
        (invocation) {
          final builder =
              invocation.positionalArguments[0] as ValueWidgetBuilder<String>;
          return builder(mockBuildContext, 'en_us', null);
        },
      );

      when(mockSessionModel.acceptedTermsVersion(any)).thenAnswer((invocation) {
        final builder =
            invocation.positionalArguments[0] as ValueWidgetBuilder<int>;
        return builder(mockBuildContext, 0, null);
      });

      when(mockSessionModel.developmentMode(any)).thenAnswer(
        (invocation) {
          final builder =
              invocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
          return builder(mockBuildContext, true, null);
        },
      );

      when(mockSessionModel.shouldShowAds(any)).thenAnswer(
        (invocation) {
          final builder =
              invocation.positionalArguments[0] as ValueWidgetBuilder<String>;
          return builder(mockBuildContext, "", null);
        },
      );

      when(mockSessionModel.isTestPlayVersion)
          .thenAnswer((realInvocation) => ValueNotifier(false));
      when(mockSessionModel.proUserNotifier)
          .thenAnswer((realInvocation) => ValueNotifier(false));
      when(mockSessionModel.isStoreVersion).thenAnswer((realInvocation) {
        return ValueNotifier(false);
      });
      when(mockSessionModel.isAuthEnabled)
          .thenAnswer((realInvocation) => ValueNotifier(true));

      when(mockSessionModel.chatEnabled(any)).thenAnswer(
        (realInvocation) {
          final builder =
              realInvocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
          return builder(mockBuildContext, false, null);
        },
      );

      when(mockSessionModel.replicaAddr(any)).thenAnswer(
        (realInvocation) {
          final builder = realInvocation.positionalArguments[0]
              as ValueWidgetBuilder<String>;
          return builder(mockBuildContext, "", null);
        },
      );

      stubSessionModel(
          mockSessionModel: mockSessionModel,
          mockBuildContext: mockBuildContext);

      when(mockSessionModel.eventManager).thenReturn(mockEventManager);
      when(mockEventManager.subscribe(any, any)).thenAnswer((realInvocation) {
        final event = realInvocation.positionalArguments[0] as Event;
        final onNewEvent =
            realInvocation.positionalArguments[1] as void Function(Event, Map);
        return () {
          onNewEvent(event, {});
        };
      });

      when(mockSessionModel.acceptedTermsVersion(any)).thenAnswer(
        (realInvocation) {
          final builder =
              realInvocation.positionalArguments[0] as ValueWidgetBuilder<int>;
          return builder(mockBuildContext, 0, null);
        },
      );

      when(mockSessionModel.isUserFirstTimeVisit())
          .thenAnswer((realInvocation) => Future.value(true));

      /// messageing model
      when(mockMessagingModel.getOnBoardingStatus(any)).thenAnswer(
        (realInvocation) {
          final builder = realInvocation.positionalArguments[0]
              as ValueWidgetBuilder<bool?>;
          return builder(mockBuildContext, null, null);
        },
      );

      stubVpnModel(
          mockVpnModel: mockVpnModel, mockBuildContext: mockBuildContext);

      await $.pumpWidget(const LanternApp());
      await $.pumpAndSettle();
      await $.pump(const Duration(seconds: 2));

      final signInFinder = $(Button).$('sign_in'.i18n.toUpperCase());
      final lanternProFinder =
          $(Button).$('get_lantern_pro'.i18n.toUpperCase());

      expect($(Button), findsExactly(2));
      expect(lanternProFinder, findsOneWidget);
      expect(signInFinder, findsOneWidget);

      when(mockSessionModel.hasUserSignedInNotifier)
          .thenReturn(ValueNotifier(false));
      when(mockSessionModel.userEmail).thenReturn(ValueNotifier(""));

      await signInFinder.tap();
      await $.pumpAndSettle();

      expect($(AuthLanding), findsNothing);
      expect($(AppBarProHeader), findsOneWidget);
      expect($('sign_in'.i18n), findsOneWidget);
    },
  );
}
