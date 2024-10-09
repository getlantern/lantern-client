import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/core/widgtes/custom_bottom_item.dart';
import 'package:lantern/features/home/home.dart';
import 'package:lantern/features/messaging/messaging_model.dart';
import 'package:lantern/features/replica/common.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';

import '../../utils/test_common.dart';
import '../../utils/widgets.dart';

// https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k
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
      sl.registerLazySingleton<MessagingModel>(() => mockMessagingModel);
      sl.registerLazySingleton<ReplicaModel>(() => mockReplicaModel);
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
    "Home widget render properly for Android",
        () {
      testWidgets(
        "Home widget started with all taps showing",
            (widgetTester) async {
          final homeWidget = MultiProvider(providers: [
            ChangeNotifierProvider<BottomBarChangeNotifier>.value(
                value: mockBottomBarChangeNotifier),
            ChangeNotifierProvider<VPNChangeNotifier>.value(
                value: mockVPNChangeNotifier),
            ChangeNotifierProvider<InternetStatusProvider>.value(
                value: mockInternetStatusProvider),
          ], child: wrapWithMaterialApp(const HomePage()));

          /// stub providers
          when(mockBottomBarChangeNotifier.currentIndex).thenReturn(TAB_VPN);


          /// Stub session model
          when(mockSessionModel.acceptedTermsVersion(any))
              .thenAnswer((invocation) {
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
          when(mockSessionModel.isStoreVersion)
              .thenAnswer((realInvocation) => ValueNotifier(false));
          when(mockSessionModel.isAuthEnabled)
              .thenAnswer((realInvocation) => ValueNotifier(false));


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
              return builder(mockBuildContext, "test", null);
            },
          );

          when(mockSessionModel.proUser(any)).thenAnswer(
                (realInvocation) {
              return boolEmptyBuilder(mockBuildContext, false, null);
            },
          );

          when(mockSessionModel.eventManager).thenReturn(mockEventManager);
          when(mockEventManager.subscribe(any, any)).thenAnswer((
              realInvocation) {
            final event = realInvocation.positionalArguments[0] as Event;
            final onNewEvent = realInvocation
                .positionalArguments[1] as void Function(Event, Map);
            return () {
              onNewEvent(event, {});
            };
          });

          ///Stub messaging model
          when(mockMessagingModel.getOnBoardingStatus(any)).thenAnswer(
                (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
              as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );


          ///stub vpn model
          when(mockVpnModel.vpnStatus(any, any)).thenAnswer((realInvocation) {
            final builder = realInvocation
                .positionalArguments[1] as ValueWidgetBuilder<String>;
            return builder(mockBuildContext, 'disconnected', null);
          },);

          ///stub replica model
          when(mockReplicaModel.getShowNewBadgeWidget(any)).thenAnswer((
              realInvocation) {
            final builder = realInvocation
                .positionalArguments[0] as ValueWidgetBuilder<bool>;
            return builder(mockBuildContext, true, null);
          },);

          await widgetTester.pumpWidget(homeWidget);

          final bottombar = find.byType(BottomNavigationBar);
          expect(bottombar, findsOneWidget);
          // three item since replica is disable
          expect(find.byType(CustomBottomBarItem), findsAtLeast(4));
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets(
        "Home widget started with replica disabled",
            (widgetTester) async {
          final homeWidget = MultiProvider(providers: [
            ChangeNotifierProvider<BottomBarChangeNotifier>.value(
                value: mockBottomBarChangeNotifier),
            ChangeNotifierProvider<VPNChangeNotifier>.value(
                value: mockVPNChangeNotifier),
            ChangeNotifierProvider<InternetStatusProvider>.value(
                value: mockInternetStatusProvider),
          ], child: wrapWithMaterialApp(const HomePage()));

          /// stub providers
          when(mockBottomBarChangeNotifier.currentIndex).thenReturn(TAB_VPN);

          /// Now stub all daa widgets
          when(mockSessionModel.acceptedTermsVersion(any))
              .thenAnswer((invocation) {
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
          when(mockSessionModel.isStoreVersion)
              .thenAnswer((realInvocation) => ValueNotifier(false));
          when(mockSessionModel.isAuthEnabled)
              .thenAnswer((realInvocation) => ValueNotifier(false));

          when(mockMessagingModel.getOnBoardingStatus(any)).thenAnswer(
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
          //
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
          when(mockEventManager.subscribe(any, any)).thenAnswer((
              realInvocation) {
            final event = realInvocation.positionalArguments[0] as Event;
            final onNewEvent = realInvocation
                .positionalArguments[1] as void Function(Event, Map);
            return () {
              onNewEvent(event, {});
            };
          });

          await widgetTester.pumpWidget(homeWidget);

          final bottombar = find.byType(BottomNavigationBar);
          expect(bottombar, findsOneWidget);
          // three item since replica is disable
          expect(find.byType(CustomBottomBarItem), findsAtLeast(3));
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );
    },
  );

  // IOS tests
  group(
    "Home widget render properly for IOS",
        () {
      testWidgets(
        "Home widget started with all taps showing",
            (widgetTester) async {
          final homeWidget = MultiProvider(providers: [
            ChangeNotifierProvider<BottomBarChangeNotifier>.value(
                value: mockBottomBarChangeNotifier),
            ChangeNotifierProvider<VPNChangeNotifier>.value(
                value: mockVPNChangeNotifier),
            ChangeNotifierProvider<InternetStatusProvider>.value(
                value: mockInternetStatusProvider),
          ], child: wrapWithMaterialApp(const HomePage()));

          /// stub providers
          when(mockBottomBarChangeNotifier.currentIndex).thenReturn(TAB_VPN);


          /// Stub session model
          when(mockSessionModel.acceptedTermsVersion(any))
              .thenAnswer((invocation) {
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
          when(mockSessionModel.isStoreVersion)
              .thenAnswer((realInvocation) => ValueNotifier(false));
          when(mockSessionModel.isAuthEnabled)
              .thenAnswer((realInvocation) => ValueNotifier(false));


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
              return builder(mockBuildContext, "", null);
            },
          );

          when(mockSessionModel.proUser(any)).thenAnswer(
                (realInvocation) {
              return boolEmptyBuilder(mockBuildContext, false, null);
            },
          );

          when(mockSessionModel.eventManager).thenReturn(mockEventManager);
          when(mockEventManager.subscribe(any, any)).thenAnswer((
              realInvocation) {
            final event = realInvocation.positionalArguments[0] as Event;
            final onNewEvent = realInvocation
                .positionalArguments[1] as void Function(Event, Map);
            return () {
              onNewEvent(event, {});
            };
          });

          ///Stub messaging model
          when(mockMessagingModel.getOnBoardingStatus(any)).thenAnswer(
                (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
              as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );


          ///stub vpn model
          when(mockVpnModel.vpnStatus(any, any)).thenAnswer((realInvocation) {
            final builder = realInvocation
                .positionalArguments[1] as ValueWidgetBuilder<String>;
            return builder(mockBuildContext, 'disconnected', null);
          },);


          await widgetTester.pumpWidget(homeWidget);

          final bottombar = find.byType(BottomNavigationBar);
          expect(bottombar, findsOneWidget);
          expect(find.byType(CustomBottomBarItem), findsAtLeast(3));
          //replica should be disable on IOS
          expect(find.text('discover'.i18n,), findsNothing);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );
    },
  );



  // Dekstop tests
  group(
    "Home widget render properly for IOS",
        () {
      testWidgets(
        "Home widget started with all taps showing",
            (widgetTester) async {
          final homeWidget = MultiProvider(providers: [
            ChangeNotifierProvider<BottomBarChangeNotifier>.value(
                value: mockBottomBarChangeNotifier),
            ChangeNotifierProvider<VPNChangeNotifier>.value(
                value: mockVPNChangeNotifier),
            ChangeNotifierProvider<InternetStatusProvider>.value(
                value: mockInternetStatusProvider),
          ], child: wrapWithMaterialApp(const HomePage()));

          /// stub providers
          when(mockBottomBarChangeNotifier.currentIndex).thenReturn(TAB_VPN);


          /// Stub session model
          when(mockSessionModel.acceptedTermsVersion(any))
              .thenAnswer((invocation) {
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
          when(mockSessionModel.isStoreVersion)
              .thenAnswer((realInvocation) => ValueNotifier(false));
          when(mockSessionModel.isAuthEnabled)
              .thenAnswer((realInvocation) => ValueNotifier(false));


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
              return builder(mockBuildContext, "", null);
            },
          );

          when(mockSessionModel.proUser(any)).thenAnswer(
                (realInvocation) {
              return boolEmptyBuilder(mockBuildContext, false, null);
            },
          );

          when(mockSessionModel.eventManager).thenReturn(mockEventManager);
          when(mockEventManager.subscribe(any, any)).thenAnswer((
              realInvocation) {
            final event = realInvocation.positionalArguments[0] as Event;
            final onNewEvent = realInvocation
                .positionalArguments[1] as void Function(Event, Map);
            return () {
              onNewEvent(event, {});
            };
          });

          ///Stub messaging model
          when(mockMessagingModel.getOnBoardingStatus(any)).thenAnswer(
                (realInvocation) {
              final builder = realInvocation.positionalArguments[0]
              as ValueWidgetBuilder<bool>;
              return builder(mockBuildContext, false, null);
            },
          );


          ///stub vpn model
          when(mockVpnModel.vpnStatus(any, any)).thenAnswer((realInvocation) {
            final builder = realInvocation
                .positionalArguments[1] as ValueWidgetBuilder<String>;
            return builder(mockBuildContext, 'disconnected', null);
          },);


          await widgetTester.pumpWidget(homeWidget);

          final bottombar = find.byType(BottomNavigationBar);
          expect(bottombar, findsOneWidget);
          expect(find.byType(CustomBottomBarItem), findsAtLeast(3));
          //replica should be disable on IOS
          expect(find.text('discover'.i18n,), findsNothing);
        },
        variant: TargetPlatformVariant.desktop(),
      );
    },
  );
}
