import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/account/split_tunneling.dart';
import 'package:lantern/features/vpn/vpn_bandwidth.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:lantern/features/vpn/vpn_pro_banner.dart';
import 'package:lantern/features/vpn/vpn_server_location.dart';
import 'package:lantern/features/vpn/vpn_switch.dart';
import 'package:lantern/features/vpn/vpn_tab.dart';

import '../../utils/test_common.dart';
import '../../utils/widgets.dart';

void main() {
  late MockSessionModel mockSessionModel;
  late MockBuildContext mockBuildContext;
  late MockBottomBarChangeNotifier mockBottomBarChangeNotifier;
  late MockVPNChangeNotifier mockVPNChangeNotifier;
  late MockInternetStatusProvider mockInternetStatusProvider;
  late MockVpnModel mockVpnModel;

  setUp(
    () {
      mockSessionModel = MockSessionModel();
      mockBuildContext = MockBuildContext();

      mockBottomBarChangeNotifier = MockBottomBarChangeNotifier();
      mockVPNChangeNotifier = MockVPNChangeNotifier();
      mockInternetStatusProvider = MockInternetStatusProvider();
      mockVpnModel = MockVpnModel();

      // Injection models
      sl.registerLazySingleton<SessionModel>(() => mockSessionModel);
      sl.registerLazySingleton<VpnModel>(() => mockVpnModel);

      // mock the providers
      mockBottomBarChangeNotifier = MockBottomBarChangeNotifier();
      mockVPNChangeNotifier = MockVPNChangeNotifier();
      mockInternetStatusProvider = MockInternetStatusProvider();
    },
  );

  tearDown(
    () {
      sl.reset();
    },
  );

  group(
    "render VPN tap",
    () {
      testWidgets(
        'render VPN tap for mobile',
        (widgetTester) async {
          final vpnTapWidget = MultiProvider(providers: [
            ChangeNotifierProvider<BottomBarChangeNotifier>.value(
                value: mockBottomBarChangeNotifier),
            ChangeNotifierProvider<VPNChangeNotifier>.value(
                value: mockVPNChangeNotifier),
            ChangeNotifierProvider<InternetStatusProvider>.value(
                value: mockInternetStatusProvider),
          ], child: wrapWithMaterialApp(const VPNTab()));

          when(mockVPNChangeNotifier.isFlashlightInitialized).thenReturn(true);

          /// session model stubs
          stubSessionModel(
            mockSessionModel: mockSessionModel,
            mockBuildContext: mockBuildContext,
          );

          ///vpn models stub
          stubVpnModel(
              mockVpnModel: mockVpnModel, mockBuildContext: mockBuildContext);

          await widgetTester.pumpWidget(vpnTapWidget);
          expect(find.byType(VPNTapSkeleton), findsNothing);
          expect(find.byType(ProBanner), findsOneWidget);
          expect(find.byType(VPNSwitch), findsOneWidget);
          expect(find.byType(ServerLocationWidget), findsOneWidget);
          expect(find.byType(SplitTunnelingWidget), findsOneWidget);
          expect(find.byType(VPNBandwidth), findsOneWidget);
          expect(find.byType(LinearProgressIndicator), findsOneWidget);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets(
        'render VPN tap for ios',
        (widgetTester) async {
          final vpnTapWidget = MultiProvider(providers: [
            ChangeNotifierProvider<BottomBarChangeNotifier>.value(
                value: mockBottomBarChangeNotifier),
            ChangeNotifierProvider<VPNChangeNotifier>.value(
                value: mockVPNChangeNotifier),
            ChangeNotifierProvider<InternetStatusProvider>.value(
                value: mockInternetStatusProvider),
          ], child: wrapWithMaterialApp(const VPNTab()));

          when(mockVPNChangeNotifier.isFlashlightInitialized).thenReturn(true);

          /// Session model stubs
          stubSessionModel(
              mockSessionModel: mockSessionModel,
              mockBuildContext: mockBuildContext);

          ///stub vpn models
          stubVpnModel(
              mockVpnModel: mockVpnModel, mockBuildContext: mockBuildContext);

          await widgetTester.pumpWidget(vpnTapWidget);
          expect(find.byType(VPNTapSkeleton), findsNothing);
          expect(find.byType(ProBanner), findsOneWidget);
          expect(find.byType(VPNSwitch), findsOneWidget);
          expect(find.byType(ServerLocationWidget), findsOneWidget);
          expect(find.byType(SplitTunnelingWidget), findsNothing);
          expect(find.byType(VPNBandwidth), findsOneWidget);
          expect(find.byType(LinearProgressIndicator), findsOneWidget);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );

      testWidgets(
        'render VPN tap for desktop',
        (widgetTester) async {
          final vpnTapWidget = MultiProvider(providers: [
            ChangeNotifierProvider<BottomBarChangeNotifier>.value(
                value: mockBottomBarChangeNotifier),
            ChangeNotifierProvider<VPNChangeNotifier>.value(
                value: mockVPNChangeNotifier),
            ChangeNotifierProvider<InternetStatusProvider>.value(
                value: mockInternetStatusProvider),
          ], child: wrapWithMaterialApp(const VPNTab()));

          when(mockVPNChangeNotifier.isFlashlightInitialized).thenReturn(true);
          when(mockVPNChangeNotifier.vpnStatus)
              .thenAnswer((realInvocation) => ValueNotifier('disconnected'));

          stubSessionModel(
              mockSessionModel: mockSessionModel,
              mockBuildContext: mockBuildContext);

          ///stub vpn models
          stubVpnModel(
              mockVpnModel: mockVpnModel, mockBuildContext: mockBuildContext);

          await widgetTester.pumpWidget(vpnTapWidget);
          expect(find.byType(VPNTapSkeleton), findsNothing);
          expect(find.byType(ProBanner), findsOneWidget);
          expect(find.byType(VPNSwitch), findsOneWidget);
          expect(find.byType(ServerLocationWidget), findsOneWidget);
          expect(find.byType(SplitTunnelingWidget), findsNothing);
          expect(find.byType(VPNBandwidth), findsOneWidget);
          expect(find.byType(LinearProgressIndicator), findsOneWidget);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    },
  );

  group(
    "render common widgets properly for al platforms",
    () {
      testWidgets(
        'render VPN tap skeleton ',
        (widgetTester) async {
          final vpnTapWidget = MultiProvider(providers: [
            ChangeNotifierProvider<BottomBarChangeNotifier>.value(
                value: mockBottomBarChangeNotifier),
            ChangeNotifierProvider<VPNChangeNotifier>.value(
                value: mockVPNChangeNotifier),
            ChangeNotifierProvider<InternetStatusProvider>.value(
                value: mockInternetStatusProvider),
          ], child: wrapWithMaterialApp(const VPNTab()));

          if (isDesktop()) {
            when(mockVPNChangeNotifier.vpnStatus)
                .thenReturn(ValueNotifier('disconnected'));
          }
          stubSessionModel(
              mockSessionModel: mockSessionModel,
              mockBuildContext: mockBuildContext);
          stubVpnModel(
              mockVpnModel: mockVpnModel, mockBuildContext: mockBuildContext);
          await widgetTester.pumpWidget(vpnTapWidget);
          expect(find.byType(VPNTapSkeleton), findsOneWidget);
        },
        variant: TargetPlatformVariant.all(excluding: {TargetPlatform.fuchsia}),
      );
    },
  );
}
