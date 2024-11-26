import 'package:integration_test/integration_test.dart';
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

///Make sure to use custom tear down function
void main() {
  if(isDesktop()){
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
  }
  appTearDown(
    () async {
      await sl.reset();
    },
  );

  patrol(
    "app start up sequence",
    ($) async {
      await $(HomePage).waitUntilVisible();
      final bottombar = find.byType(BottomNavigationBar);
      expect(bottombar, findsOneWidget);
    },
  );
}
