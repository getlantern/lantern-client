import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/app.dart';
import 'package:lantern/core/utils/common.dart';

import '../enums/screens_test.dart';
import '../helpers/waiter_test.dart';

class GoTo {
  /// NavigateTo is used to handle the navigation flow from one screen to another.
  /// the navigation is based on the Origin and Destination screens.
  /// So we can have more than 1 scenario were we can navigate from one screen to another by more than 1 way.
  static Future<void> navigateTo(
    WidgetTester tester, {
    SCREENS from = SCREENS.MAIN,
    to = SCREENS.MESSAGES,
  }) async {
    switch (to) {
      case SCREENS.MAIN:
      case SCREENS.MESSAGES:
        await tester.pumpWidget(LanternApp());
        await tester.pumpAndSettle();
        print('This pump and settle is used for 2 reasons');
        print('1. The settle happens after the main has been completed');
        print(
          '2. Autoroute is still building so the second settle is just to await for that process to be completed',
        );
        await tester.pumpAndSettle();
        break;
      case SCREENS.CONTACTS:
        if (from == SCREENS.MESSAGES) {
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
        }
        break;
      case SCREENS.CONVERSATION:
        if (from == SCREENS.MESSAGES) {
          await tester
              .tap(find.widgetWithText(ListItemFactory, 'Note to self'));
          await awaitFor(tester, duration: const Duration(seconds: 1));
          find.widgetWithText(ListItemFactory, 'Note to self');
        }
        if (from == SCREENS.CONTACTS) {
          await tester
              .tap(find.widgetWithText(ListItemFactory, 'Note to self'));
          await awaitFor(tester, duration: const Duration(seconds: 1));
        }
        break;
      default:
        return;
    }
  }

  static Future<void> navigateBack(WidgetTester tester) async {
    await tester.pageBack();
    await tester.pumpAndSettle();
  }
}
