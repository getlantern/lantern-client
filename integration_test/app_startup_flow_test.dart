import 'package:lantern/core/widgtes/custom_bottom_bar.dart';
import 'package:lantern/features/home/home.dart';

import 'utils/test_utils.dart';

/// Looks like patrol does not have native support yet for Linux and Windows
/// so any test that interact with the native layer will / need to use flutter test
/// patrol feature priority:https://patrol.leancode.co/native/feature-parity
/// finder documentation: https://patrol.leancode.co/finders/usage

///1
/// if you want to interact with the native layer, then user patrolTest
/// For running patrolTest, you need to run the patrol test --target integration_test/$fileName
///Make sure using this test will run as native test and not as a flutter test
///So use this only when you need to interact with the native layer

/// 2
/// if you do not want not to interact with the native layer, then use patrolWidgetTest
/// For running patrolWidgetTest, you need to run the patrol test or flutter test both will work

// Implement coverage for the test
// https://codewithandrea.com/articles/flutter-test-coverage/
// https://github.com/flutter/flutter/issues/101031
// https://stackoverflow.com/questions/61535142/how-to-use-dylibs-from-a-plugin-inside-a-macos-sandboxed-application
// https://github.com/flutter/flutter/issues/135673

// IOS Related issues
// https://github.com/leancodepl/patrol/issues/2159
// https://github.com/leancodepl/patrol/issues/1871
// https://stackoverflow.com/questions/54875362/firebase-test-lab-ios-app-not-being-installed
// https://stackoverflow.com/questions/54450113/how-to-handle-code-signing-for-ios-testing-on-firebase-test-lab-through-ci
///Make sure to use custom tear down function

void main() {

}
