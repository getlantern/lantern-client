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
    'checkout flow end to end test',
    ($) async {
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

      // check if payment is available or not
      final stripeFound = $.tester.any(find.byTooltip(Providers.stripe.name));
      if (!stripeFound) {
        print('Payment method not available. Skipping test.');
        return;
      }

      // Check if continue button is disabled
      final continueBtn = $.tester.widget<Button>($(Button));
      expect(continueBtn.disabled, true);

      await $(CTextField).enterText(
        "test@getlantern.org",
      );
      FocusManager.instance.primaryFocus?.unfocus();
      final stipeProvider = find.byTooltip(Providers.stripe.name);
      await $.tester.tap(stipeProvider);
      await $('continue'.i18n.toUpperCase()).tap();
      await $.pumpAndSettle();

      if (isAndroid()) {
        expect($(CTextField), findsExactly(3));
        expect($(PriceSummary), findsOneWidget);
      } else {
        expect($(AppWebView), findsOneWidget);
        expect($(AppWebView).visible, true);
      }

      // go back
      await $(IconButton).tap();
      await $.pump(const Duration(seconds: 1));

      /// Check out flow for shepherd
      final shepherdFound =
          $.tester.any(find.byTooltip(Providers.shepherd.name));
      if (shepherdFound) {
        final shepherdProvider = find.byTooltip(Providers.shepherd.name);
        await $.tester.tap(shepherdProvider);
        await $('continue'.i18n.toUpperCase()).tap();
        await $.pumpAndSettle();

        final loading = $(CircularProgressIndicator).visible;
        while (loading) {
          await $.pump(const Duration(seconds: 1));
        }
        expect($(AppWebView), findsOneWidget);
        expect($(AppWebView).visible, true);
        await $(IconButton).tap();
        await $.pump(const Duration(seconds: 1));
      }

      /// Check out flow for froPay
      final froPayFound = $.tester.any(find.byTooltip(Providers.fropay.name));
      if (froPayFound) {
        final froPayProvider = find.byTooltip(Providers.fropay.name);
        await $.tester.tap(froPayProvider);
        await $('continue'.i18n.toUpperCase()).tap();
        await $.pumpAndSettle();

        final loading = $(CircularProgressIndicator).visible;
        while (loading) {
          await $.pump(const Duration(seconds: 1));
        }
        expect($(AppWebView), findsOneWidget);
        expect($(AppWebView).visible, true);
      }
    },
  );
}
