
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

export  'package:lantern/core/utils/common.dart' hide Verification;
export  'test.mocks.mocks.dart';
export  'package:mockito/mockito.dart';
export  'package:flutter_test/flutter_test.dart';


class MockBuildContext extends Mock implements BuildContext {}





///Empty builder we can reuse across the test
ValueWidgetBuilder<int> intEmptyBuilder = (context, value, child) => const SizedBox();
ValueWidgetBuilder<double> doubleEmptyBuilder = (context, value, child) => const SizedBox();
ValueWidgetBuilder<bool> boolEmptyBuilder = (context, value, child) => const SizedBox();





