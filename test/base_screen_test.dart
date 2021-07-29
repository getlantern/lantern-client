import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/app.dart';

void main() {
  group(
    'Widget startup',
    () {
      testWidgets(
        'Test coverage for base_screen.dart',
        (WidgetTester tester) async {
          print('Load the root widget without catcher');
          await tester.pumpWidget(LanternApp());

          var baseScreen = find.byType(BaseScreen);
          print('Check for the BaseScreen to be loaded correctly');
          expect(baseScreen, findsOneWidget);

          var customAppbar = find.byType(CustomAppBar);
          print('Check for the CustomAppBar to be loaded correctly');
          expect(customAppbar, findsOneWidget);

          var homePage = find.byType(HomePage);
          print('Check for the HomePage to be loaded correctly');
          expect(homePage, findsOneWidget);
        },
      );
    },
  );
}
