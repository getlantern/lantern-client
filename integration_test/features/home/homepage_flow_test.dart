import 'package:flutter/material.dart';
import 'package:lantern/app.dart';
import 'package:lantern/features/account/account_tab.dart';
import 'package:lantern/features/home/home.dart';
import 'package:lantern/main.dart' as app;

import '../../utils/test_utils.dart';

void main() {
  late MockSessionModel mockSessionModel;

  setUp(
    () {
      mockSessionModel = MockSessionModel();

      sl.registerSingleton<SessionModel>(mockSessionModel);
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
          expect($('VPN'.i18n), findsOne);
          expect($('Account'.i18n), findsOne);
          expect($('VPN'.i18n).visible, equals(true));
          expect($('Account'.i18n).visible, equals(true));

          await $('Account').tap();
          await $.pumpAndSettle();

          expect($(AccountTab), findsOneWidget);
          expect($(AppBar), findsOneWidget);
        },
      );

      patrolWidgetTest(
        'home widget for appstore and play store ',
        ($) async {
          await $.pumpWidget(const LanternApp());
          await $.pumpAndSettle();
          await $(HomePage).waitUntilVisible();

          expect($(BottomNavigationBar), findsOneWidget);
        },
      );
    },
  );
}
