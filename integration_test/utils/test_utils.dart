import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:lantern/core/service/injection_container.dart';
export 'package:lantern/features/home/session_model.dart';
export 'package:lantern/features/replica/common.dart';
export 'package:mockito/mockito.dart';
export 'package:patrol/patrol.dart';

export '../../test/utils/test.mocks.mocks.dart';

TestVariant isMobile() {
  return const TargetPlatformVariant(
      {TargetPlatform.android, TargetPlatform.iOS});
}