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

/// Use this function to write tests for integration test
/// this methods uses custom patrol for mobile version and for desktop it uses patrolWidgetTest that extension of flutter test
/// Since desktop does not interface with native layer uses same
///Faq there is issue with patrol with native layer
///https://stackoverflow.com/questions/61535142/how-to-use-dylibs-from-a-plugin-inside-a-macos-sandboxed-application
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
      ($) async {
        if (initApp) {
          await _createApp($);
        }

        await callback($);
      },
      config: _patrolTesterConfig,
      skip: skip,
      tags: tags,
      variant: variant,
    );
  } else {
    patrolTest(
      description,
      ($) async {
        if (initApp) {
          await _createApp($);
        }
        await callback($);
      },
      config: _patrolTesterConfig,
      nativeAutomatorConfig: nativeAutomatorConfig ?? _nativeAutomatorConfig,
      skip: skip,
      tags: tags,
      variant: variant,
    );
  }
}

/// Make sure to use this function to tear down the test
/// this will reset according to which platform you are running
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
