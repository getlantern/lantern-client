import 'package:lantern/core/utils/utils.dart';
import 'package:lantern/features/checkout/payment_provider.dart';
import 'package:lantern/features/checkout/plan_details.dart';
import 'package:lantern/features/checkout/price_summary.dart';
import 'package:lantern/features/vpn/vpn_switch.dart';

import '../../utils/test_utils.dart';

void main() {
  appTearDown(
    () async {
      await sl.reset();
    },
  );

  patrol(
    skip: isiOS(),
    'stripe checkout flow end to end test',
    (pTester) async {
      final $ = pTester as PatrolIntegrationTester;
      await $(VPNSwitch).waitUntilVisible();
      await $('Account'.i18n).tap();
      await $.pumpAndSettle();

      if (sessionModel.proUserNotifier.value == false) {
        await $(AppKeys.upgrade_lantern_pro).tap();
        await $.pumpAndSettle();
      } else {
        return;
      }

      expect($(PlanCard), findsAtLeast(2));
      expect($(PlanCard).at(0).visible, true);

      await $(PlanCard).at(0).tap();

      expect($('lantern_pro_checkout'.i18n), findsOneWidget);
      expect($(PaymentProvider), findsAtLeast(1));

      // Check if continue button is disabled
      final continueBtn = $.tester.widget<Button>($(Button));
      expect(continueBtn.disabled, true);

      await $(CTextField).enterText("test@getlantern.org");
      final stipeProvider=  find.byTooltip(Providers.stripe.name);
      await $.tester.tap(stipeProvider);
      await $('continue'.i18n.toUpperCase()).tap();
      await $.pumpAndSettle();

      if (isAndroid()) {
        expect($(CTextField), findsExactly(3));
        expect($(PriceSummary), findsOneWidget);
      } else {
        expect($(AppWebView), findsOneWidget);
        expect($(AppWebView).visible, true);
        expect($('BNS'), findsOneWidget);
      }
    },
  );
}
