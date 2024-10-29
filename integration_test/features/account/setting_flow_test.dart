import 'package:flutter/cupertino.dart';
import 'package:lantern/core/widgtes/version_footer.dart';
import 'package:lantern/features/account/split_tunneling.dart';

import '../../utils/test_utils.dart';

void main() {
  group(
    "setting end to end",
    () {
      patrolWidget(
        'render setting and navigation test ',
        ($) async {
          await $('Account'.i18n).tap();
          await $.pumpAndSettle();
          await $(AppKeys.setting).tap();
          await $.pumpAndSettle();

          expect($(AppKeys.language).visible, true);
          expect($(AppKeys.checkForUpdates).visible, true);
          if (isAndroid()) {
            await $(AppKeys.splitTunneling).waitUntilVisible();
            expect($(AppKeys.splitTunneling).visible, true);
          } else {
            expect($(AppKeys.splitTunneling), findsNothing);
          }

          if (isDesktop()) {
            expect($(AppKeys.proxyAll).visible, true);
            expect($(AppKeys.proxySetting).visible, true);
          } else {
            expect($(AppKeys.proxyAll), findsNothing);
            expect($(AppKeys.proxySetting), findsNothing);
          }

          expect($(AppKeys.privacyPolicy).visible, true);
          expect($(AppKeys.termsOfServices).visible, true);
          expect($(VersionFooter).visible, true);

          //language
          await $(AppKeys.language).tap();
          await $.pumpAndSettle();

          expect($(CText).$('language'.i18n), findsOneWidget);
          expect($(ListView).visible, true);
          expect($(ListView).visible, true);
          expect($(ListView), findsOneWidget);
          expect($(RadioListTile<String>), findsAtLeast(1));
          await $(IconButton).tap();

          if (isAndroid()) {
            //split tunneling
            await $(AppKeys.splitTunneling).tap();
            await $.pumpAndSettle();

            expect($(CText).$('split_tunneling'.i18n), findsOneWidget);
            final switchFinder = $(CupertinoSwitch);
            expect(switchFinder, findsOneWidget);
            CupertinoSwitch cupertinoSwitch =
                $.tester.widget<CupertinoSwitch>(switchFinder);
            if (cupertinoSwitch.value) {
              expect($(CText).$('apps_to_unblock'.i18n), findsOneWidget);
            } else {
              expect($(CText).$('split_tunneling_info'.i18n), findsOneWidget);
            }

            if (!cupertinoSwitch.value) {
              expect($(SplitTunnelingAppsList), findsNothing);
              await switchFinder.tap();
              await $.pumpAndTrySettle();
              await $.pump(const Duration(seconds: 2));
              expect($(SplitTunnelingAppsList), findsOneWidget);
            } else {
              expect($(SplitTunnelingAppsList), findsOneWidget);
              await switchFinder.tap();
              await $.pumpAndTrySettle();
              await $.pump(const Duration(seconds: 2));
              expect($(SplitTunnelingAppsList), findsNothing);
            }
            await $(IconButton).tap();
          }

          //proxy setting
          if (isDesktop()) {
            await $(AppKeys.proxySetting).tap();
            await $.pumpAndSettle();
            expect($(CText).$('proxy_settings'.i18n), findsOneWidget);
            expect($(AppKeys.httpProxy).visible, true);
            expect($(AppKeys.socksProxy).visible, true);
            await $(IconButton).tap();
          }
        },
      );
    },
  );
}
