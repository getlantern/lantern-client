import 'package:lantern/features/home/home.dart';

import '../test/utils/test_common.dart';
import 'utils/test_utils.dart';
import 'package:lantern/main.dart' as app;
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
void main() {
  patrolWidgetTest(
    "app start up sequence",
    ($) async {
      await app.main();
      await $.pumpAndSettle();
      await $(HomePage).waitUntilVisible();
      final bottombar = find.byType(BottomNavigationBar);
      expect(bottombar, findsOneWidget);
    },
  );
}
