import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:lantern/features/vpn/vpn_switch.dart';
import 'package:patrol/patrol.dart';

import '../../utils/test_common.dart';
import '../../utils/widgets.dart';

void main() {
  late MockSessionModel mockSessionModel;
  late MockBuildContext mockBuildContext;
  late MockVPNChangeNotifier mockVPNChangeNotifier;
  late MockInternetStatusProvider mockInternetStatusProvider;
  late MockVpnModel mockVpnModel;

  setUpAll(
    () {
      mockSessionModel = MockSessionModel();
      mockBuildContext = MockBuildContext();

      mockVPNChangeNotifier = MockVPNChangeNotifier();
      mockInternetStatusProvider = MockInternetStatusProvider();
      mockVpnModel = MockVpnModel();

      // mock the providers
      mockVPNChangeNotifier = MockVPNChangeNotifier();
      mockInternetStatusProvider = MockInternetStatusProvider();

      // Injection models
      sl.registerLazySingleton<SessionModel>(() => mockSessionModel);
      sl.registerLazySingleton<VpnModel>(() => mockVpnModel);
    },
  );

  tearDown(
    () {},
  );

  patrolWidgetTest(
    "VPN switch end to end",
    ($) async {
      final vpnSwitchWidget = MultiProvider(providers: [
        ChangeNotifierProvider<VPNChangeNotifier>.value(
            value: mockVPNChangeNotifier),
        ChangeNotifierProvider<InternetStatusProvider>.value(
            value: mockInternetStatusProvider),
      ], child: wrapWithMaterialApp(const VPNSwitch()));

      when(mockInternetStatusProvider.isConnected).thenReturn(true);
      when(mockVPNChangeNotifier.isFlashlightInitializedFailed)
          .thenReturn(false);
      when(mockVPNChangeNotifier.isFlashlightInitialized).thenReturn(true);

      if (isDesktop()) {
        when(mockVPNChangeNotifier.vpnStatus)
            .thenReturn(ValueNotifier(TestVPNStatus.disconnected.name));
      } else {
        when(mockSessionModel.shouldShowAds(any)).thenAnswer((invocation) {
          final builder =
              invocation.positionalArguments[0] as ValueWidgetBuilder<String>;
          return builder(mockBuildContext, "", null);
        });

        when(mockVpnModel.vpnStatus(mockBuildContext, any))
            .thenAnswer((invocation) {
          final builder =
              invocation.positionalArguments[1] as ValueWidgetBuilder<String>;
          return builder(
              mockBuildContext, TestVPNStatus.disconnected.name, null);
        });
      }

      await $.pumpWidget(vpnSwitchWidget);
      await $.pumpAndSettle();

      if (isMobile()) {
        final vpnSwitch = $.tester.widget<AdvancedSwitch>($(AdvancedSwitch));
        expect($(AdvancedSwitch), findsOneWidget);
        expect(vpnSwitch.inactiveColor, offSwitchColor);
      } else {
        // Desktop version
        expect($(CustomAnimatedToggleSwitch<String>), findsOneWidget);
      }

      if (isDesktop()) {
        when(mockVPNChangeNotifier.vpnStatus)
            .thenReturn(ValueNotifier(TestVPNStatus.connected.name));
      } else {
        when(mockVpnModel.vpnStatus(mockBuildContext, any))
            .thenAnswer((invocation) {
          final builder =
              invocation.positionalArguments[1] as ValueWidgetBuilder<String>;
          return builder(mockBuildContext, TestVPNStatus.connected.name, null);
        });
      }

      await $.pump(const Duration(seconds: 1));

      if (isMobile()) {
        final vpnSwitch = $.tester.widget<AdvancedSwitch>($(AdvancedSwitch));
        expect($(AdvancedSwitch), findsOneWidget);
        expect(vpnSwitch.enabled, true);
        expect(vpnSwitch.activeColor, onSwitchColor);
        expect(vpnSwitch.width, 150);
        expect(vpnSwitch.height, 70);
      } else {
        final vpnSwitchDesktop = $.tester.widget<CustomAnimatedToggleSwitch>(
            $(CustomAnimatedToggleSwitch<String>));
        // Desktop version
        expect($(CustomAnimatedToggleSwitch<String>), findsOneWidget);
        expect(vpnSwitchDesktop.active, true);
        expect(vpnSwitchDesktop.height, 72);
      }
    },
    variant: TargetPlatformVariant.all(
      excluding: {TargetPlatform.fuchsia},
    ),
  );
}
