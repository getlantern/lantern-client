import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/main.dart' as app;
import 'package:patrol/patrol.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:lantern/core/service/injection_container.dart';
export 'package:lantern/features/home/session_model.dart';
export 'package:lantern/features/replica/common.dart';
export 'package:mockito/mockito.dart';
export 'package:patrol/patrol.dart';

export  'package:lantern/core/utils/common.dart' hide Notification, Selector, Verification;

export '../../test/utils/test.mocks.mocks.dart';

final _patrolTesterConfig = const PatrolTesterConfig();
final _nativeAutomatorConfig = const NativeAutomatorConfig(
  findTimeout: Duration(seconds: 20),
);

TestVariant mobileVariant() {
  return const TargetPlatformVariant(
      {TargetPlatform.android, TargetPlatform.iOS});
}
bool shouldSkipNative(){
  if(isMobile()){
    final bool isNative = const String.fromEnvironment('native', defaultValue: 'false') == 'true';
    print("isNative: $isNative");
    print("isNative return value: ${!isNative}");
    return !isNative;
  }
  return true;
}
bool isNative(){
  return   const String.fromEnvironment('native', defaultValue: 'false') == 'true';
}

/// Use this function to interact with the native layer.
/// Avoid using it on desktop platforms and most parts of mobile platforms.
/// Should be used only on when VPN turn on/off
void patrolNative(
  String description,
  Future<void> Function(PatrolIntegrationTester $) callback, {
  bool? skip,
  List<String> tags = const [],
  NativeAutomatorConfig? nativeAutomatorConfig,
  LiveTestWidgetsFlutterBindingFramePolicy framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fadePointers,
}) {

  /// if we are not running native test then return
  if(!isNative()){
    return;
  }
  patrolTest(
    description,
    config: _patrolTesterConfig,
    nativeAutomatorConfig: nativeAutomatorConfig ?? _nativeAutomatorConfig,
    framePolicy: framePolicy,
    skip: skip,
    callback,
    tags: tags,
  );
}

Future<void> createApp(PatrolIntegrationTester $) async {
  await app.main();
  await $.pumpAndSettle();
}
