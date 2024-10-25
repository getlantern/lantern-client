import 'dart:ui' as ui;

import 'package:lantern/core/utils/common.dart';

export 'package:fixnum/fixnum.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:lantern/core/utils/common.dart' hide Verification;
export 'package:mockito/mockito.dart';

export 'test.mocks.mocks.dart';
export 'stubs.dart';

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
