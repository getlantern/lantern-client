import 'package:flutter/material.dart';
import 'package:lantern/features/account/account_tab.dart';
import 'package:lantern/features/home/home.dart';
import 'package:lantern/main.dart' as app;

import '../../utils/test_utils.dart';

/// This file contains end-to-end tests for the home page flow.
/// These tests should not use mocks to ensure the app works as expected in production.
/// This helps verify that the app functions correctly in real-world scenarios.
/// For mock tests, refer to [homepage_flow_mock_test.dart].
void main() {
  setUp(
    () {},
  );

  tearDown(
    () {
      sl.reset();
    },
  );

  group(
    'home page flow end to end test',
    () {
      patrolWidgetTest(
        'app initializes and navigates to homepage',
        ($) async {
          await app.main();

          await $.pumpAndSettle();

          await $(HomePage).waitUntilVisible();

          expect($(BottomNavigationBar), findsOneWidget);
          expect($('VPN'.i18n).visible, equals(true));
          expect($('Account'.i18n).visible, equals(true));

          await $('Account').tap();
          await $.pumpAndSettle();

          expect($(AccountTab), findsOneWidget);
          expect($(AppBar), findsOneWidget);
        },
      );
    },
  );
}
