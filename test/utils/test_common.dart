import 'dart:ui' as ui;

import '../../integration_test/utils/test_utils.dart';

export 'package:fixnum/fixnum.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:lantern/core/utils/common.dart' hide Verification;
export 'package:mockito/mockito.dart';

export 'stubs.dart';
export 'test.mocks.mocks.dart';

///Empty builder we can reuse across the test
ValueWidgetBuilder<int> intEmptyBuilder =
    (context, value, child) => const SizedBox();
ValueWidgetBuilder<double> doubleEmptyBuilder =
    (context, value, child) => const SizedBox();
ValueWidgetBuilder<bool> boolEmptyBuilder =
    (context, value, child) => const SizedBox();
ValueWidgetBuilder<bool?> boolNullableEmptyBuilder =
    (context, value, child) => const SizedBox();
ValueWidgetBuilder<String> stringEmptyBuilder =
    (context, value, child) => const SizedBox();

final desktopWindowSize = const ui.Size(360, 712);

enum TestVPNStatus {
  connected,
  disconnected,
  connecting,
  disconnecting,
}

extension Status on TestVPNStatus {
  String get value {
    switch (this) {
      case TestVPNStatus.connected:
        return 'connected';
      case TestVPNStatus.disconnected:
        return 'disconnected';
      case TestVPNStatus.connecting:
        return 'connecting';
      case TestVPNStatus.disconnecting:
        return 'disconnecting';
    }
  }
}

String normalizeSpaces(String input) {
  return input.replaceAll(RegExp(r'\s+'), ' ');
}

void mockStartApp({
  required MockSessionModel mockSessionModel,
  required MockBottomBarChangeNotifier mockBottomBarChangeNotifier,
  required MockVPNChangeNotifier mockVPNChangeNotifier,
  required MockMessagingModel mockMessagingModel,
  required MockEventManager mockEventManager,
  required BuildContext mockBuildContext,
  required MockVpnModel mockVpnModel,
  MockTestUtils mockTestUtils = const MockTestUtils()
}) {
  // Notifiers
  when(mockBottomBarChangeNotifier.currentIndex).thenReturn(TAB_VPN);
  when(mockVPNChangeNotifier.vpnStatus)
      .thenReturn(ValueNotifier(TestVPNStatus.disconnected.value));
  //Stub session Model
  if (isMobile()) {
    when(mockSessionModel.shouldShowAds(any)).thenAnswer(
      (realInvocation) {
        final builder =
            realInvocation.positionalArguments[0] as ValueWidgetBuilder<String>;
        return builder(mockBuildContext, '', null);
      },
    );
  }

  when(mockSessionModel.isTestPlayVersion).thenReturn(ValueNotifier(false));
  when(mockSessionModel.isStoreVersion).thenReturn(ValueNotifier(false));
  when(mockSessionModel.isAuthEnabled).thenReturn(ValueNotifier(false));
  when(mockSessionModel.proxyAvailable).thenReturn(ValueNotifier(mockTestUtils.proxyAvailable));
  when(mockSessionModel.pathValueNotifier(any, false))
      .thenReturn(ValueNotifier(true));
  when(mockSessionModel.language(any)).thenAnswer(
    (realInvocation) {
      final builder =
          realInvocation.positionalArguments[0] as ValueWidgetBuilder<String>;
      return builder(mockBuildContext, 'en_us', null);
    },
  );
  when(mockSessionModel.replicaAddr(any)).thenAnswer(
    (realInvocation) {
      final builder =
          realInvocation.positionalArguments[0] as ValueWidgetBuilder<String>;
      return builder(mockBuildContext, '', null);
    },
  );

  when(mockSessionModel.proUser(any)).thenAnswer(
    (realInvocation) {
      final builder =
          realInvocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
      return builder(mockBuildContext, false, null);
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

  when(mockSessionModel.chatEnabled(any)).thenAnswer(
    (realInvocation) {
      final builder =
          realInvocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
      return builder(mockBuildContext, false, null);
    },
  );

  when(mockSessionModel.developmentMode(any)).thenAnswer(
    (realInvocation) {
      final builder =
          realInvocation.positionalArguments[0] as ValueWidgetBuilder<bool>;
      return builder(mockBuildContext, false, null);
    },
  );

  // stub message model
  when(mockMessagingModel.getOnBoardingStatus(any)).thenAnswer(
    (realInvocation) {
      final builder =
          realInvocation.positionalArguments[0] as ValueWidgetBuilder<bool?>;
      return builder(mockBuildContext, null, null);
    },
  );

  // mock vpn model
  when(mockVpnModel.vpnStatus(mockBuildContext, any)).thenAnswer(
    (realInvocation) {
      final builder =
          realInvocation.positionalArguments[1] as ValueWidgetBuilder<String>;
      return builder(mockBuildContext, TestVPNStatus.disconnected.value, null);
    },
  );
}

class MockTestUtils {
  final bool proxyAvailable;

  const MockTestUtils({
    this.proxyAvailable = true,
  });
}
