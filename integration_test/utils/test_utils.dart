import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/main.dart' as app;
import 'package:meta/meta.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_finders/src/custom_finders/patrol_tester.dart';
import 'package:window_manager/window_manager.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:lantern/core/service/injection_container.dart';
export 'package:lantern/core/utils/common.dart'
    hide Notification, Selector, Verification;
export 'package:lantern/features/home/session_model.dart';
export 'package:lantern/features/replica/common.dart';
export 'package:mockito/mockito.dart';
export 'package:patrol/patrol.dart';

export '../../test/utils/test.mocks.mocks.dart';

final _patrolTesterConfig = const PatrolTesterConfig();
final _nativeAutomatorConfig = const NativeAutomatorConfig(
  findTimeout: Duration(seconds: 20),
);

TestVariant mobileVariant() {
  return const TargetPlatformVariant(
      {TargetPlatform.android, TargetPlatform.iOS});
}

TestVariant androidVariant() {
  return const TargetPlatformVariant({TargetPlatform.android});
}

bool shouldSkipNative() {
  if (isMobile()) {
    final bool isNative =
        const String.fromEnvironment('native', defaultValue: 'false') == 'true';
    return !isNative;
  }
  return true;
}

bool isNative() {
  return const String.fromEnvironment('native', defaultValue: 'false') ==
      'true';
}

/// Use this function to interact with the widget layer.
/// Should be used on desktop platforms and most parts of mobile platforms.
/// Should be used only when testing the UI.
/// Avoid using it on when VPN turn on/off for mobile since it needs to interact with the native layer.
/// App is already created in this function.
@isTest
void patrol(
  String description,
  Future<void> Function(PatrolTester $) callback, {
  bool? skip,
  List<String> tags = const [],
  NativeAutomatorConfig? nativeAutomatorConfig,
  TestVariant variant = const DefaultTestVariant(),
  bool initApp = true,
}) {
  if (isDesktop()) {
    patrolWidgetTest(
      description,
      config: _patrolTesterConfig,
      skip: skip,
      ($) async {
        if (initApp) {
          await _createApp($);
        }

        await callback($);
      },
      tags: tags,
      variant: variant,
    );
  } else {
    patrolTest(
      description,
      config: _patrolTesterConfig,
      skip: skip,
      ($) async {
        if (initApp) {
          await _createApp($);
        }
        await callback($);
      },
      tags: tags,
      variant: variant,
    );
  }
}

void appTearDown(dynamic Function() body) {
  if (isMobile()) {
    patrolTearDown(body);
  } else {
    tearDown(body);
  }
}

Future<void> initDesktopTestServices() async {
  if (!isDesktop()) return;
  if (Platform.isWindows) await initializeWebViewEnvironment();
  await windowManager.ensureInitialized();
  await windowManager.setSize(const Size(360, 712));
}



Future<void> _createApp(PatrolTester $) async {
  await app.main(testMode: true);
  await $.pumpAndSettle();
}
