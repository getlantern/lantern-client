import 'package:fixnum/fixnum.dart';
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
  late MockMessagingModel mockMessagingModel;
  late MockBottomBarChangeNotifier mockBottomBarChangeNotifier;
  late MockVPNChangeNotifier mockVPNChangeNotifier;
  late MockInternetStatusProvider mockInternetStatusProvider;
  late MockReplicaModel mockReplicaModel;
  late MockVpnModel mockVpnModel;
  late MockEventManager mockEventManager;

  setUpAll(
    () {
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
      // sl.registerLazySingleton<MessagingModel>(() => mockMessagingModel);
      // sl.registerLazySingleton<ReplicaModel>(() => mockReplicaModel);
      sl.registerLazySingleton<VpnModel>(() => mockVpnModel);

      // mock the providers
      mockBottomBarChangeNotifier = MockBottomBarChangeNotifier();
      mockVPNChangeNotifier = MockVPNChangeNotifier();
      mockInternetStatusProvider = MockInternetStatusProvider();
    },
  );

  tearDownAll(
    () {
      sl.reset();
    },
  );
  group(
    "render VPN tap for mobile",
    () {
      testWidgets(
        'render VPN tap skeleton for mobile',
        (widgetTester) async {
          final vpnTapWidget = MultiProvider(providers: [
            ChangeNotifierProvider<BottomBarChangeNotifier>.value(
                value: mockBottomBarChangeNotifier),
            ChangeNotifierProvider<VPNChangeNotifier>.value(
                value: mockVPNChangeNotifier),
            ChangeNotifierProvider<InternetStatusProvider>.value(
                value: mockInternetStatusProvider),
          ], child: wrapWithMaterialApp(const VPNTab()));

          when(mockSessionModel.proUser(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
                  as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );

          when(mockSessionModel.shouldShowAds(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
                  as ValueWidgetBuilder<String>;
              return builder(mockBuildContext, "", null);
            },
          );

          when(mockSessionModel.proxyAvailable)
              .thenAnswer((realInvocation) => ValueNotifier(true));

          ///stub vpn models

          when(mockVpnModel.vpnStatus(any, any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[1]
                  as ValueWidgetBuilder<String>;
              return builder(mockBuildContext, 'disconnected', null);
            },
          );

          await widgetTester.pumpWidget(vpnTapWidget);

          expect(find.byType(VPNTapSkeleton), findsOneWidget);
        },
      );

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

          /// Session model stubs
          when(mockSessionModel.proxyAvailable)
              .thenAnswer((realInvocation) => ValueNotifier(true));
          when(mockSessionModel.proUser(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
                  as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );


          when(mockSessionModel.shouldShowAds(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
                  as ValueWidgetBuilder<String>;
              return builder(mockBuildContext, "", null);
            },
          );

          when(mockSessionModel.serverInfo(any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
                  as ValueWidgetBuilder<ServerInfo?>;
              return builder(mockBuildContext, null, null);
            },
          );

          when(mockSessionModel.bandwidth(any)).thenAnswer((realInvocation) {
            final builder = realInvocation.positionalArguments[0]
                as ValueWidgetBuilder<Bandwidth>;
            var bandwidth = Bandwidth()
              ..allowed = Int64(250)
              ..remaining = Int64(200)
              ..percent = Int64(20);

            return builder(mockBuildContext, bandwidth, null);
          });

          when(mockSessionModel.splitTunneling(any)).thenAnswer(
                (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
              as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );

          ///stub vpn models
          when(mockVpnModel.vpnStatus(any, any)).thenAnswer(
            (realInvocation) {
              final builder = realInvocation.positionalArguments[1]
                  as ValueWidgetBuilder<String>;
              return builder(mockBuildContext, 'disconnected', null);
            },
          );

          await widgetTester.pumpWidget(vpnTapWidget);

          expect(find.byType(VPNTapSkeleton), findsNothing);
          expect(find.byType(ProBanner), findsOneWidget);
          expect(find.byType(VPNSwitch), findsOneWidget);
          expect(find.byType(ServerLocationWidget), findsOneWidget);
          expect(find.byType(SplitTunnelingWidget), findsOneWidget);
          expect(find.byType(VPNBandwidth), findsNothing);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );
    },
  );
}
