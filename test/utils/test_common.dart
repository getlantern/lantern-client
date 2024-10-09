
import 'package:flutter/material.dart';
import 'package:lantern/common/ui/custom/internet_checker.dart';
import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/vpn/vpn_notifier.dart';
import 'package:mockito/mockito.dart';
import 'dart:ui' as ui;
export  'package:lantern/core/utils/common.dart' hide Verification;
export  'test.mocks.mocks.dart';
export  'package:mockito/mockito.dart';
export  'package:flutter_test/flutter_test.dart';


class MockBuildContext extends Mock implements BuildContext {}



///Empty builder we can reuse across the test
ValueWidgetBuilder<int> intEmptyBuilder = (context, value, child) => const SizedBox();
ValueWidgetBuilder<double> doubleEmptyBuilder = (context, value, child) => const SizedBox();
ValueWidgetBuilder<bool> boolEmptyBuilder = (context, value, child) => const SizedBox();
ValueWidgetBuilder<bool?> boolNullableEmptyBuilder = (context, value, child) => const SizedBox();
ValueWidgetBuilder<String> stringEmptyBuilder = (context, value, child) => const SizedBox();


final desktopWindowSize = const ui.Size(360, 712);


///Utils mock





