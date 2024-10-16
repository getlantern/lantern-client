import 'package:lantern/core/service/app_purchase.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/utils.dart';

class PriceSummary extends StatelessWidget {
  final Plan plan;
  final String? refCode;
  final bool isPro;

  const PriceSummary({
    super.key,
    required this.plan,
    required this.isPro,
    this.refCode,
  });

  @override
  Widget build(BuildContext context) {
    final bonus = plan.formattedBonus;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8.0),
      child: Column(
        children: [
          const CDivider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CText(getPlanDisplayName(plan.id), style: tsOverline),
              CText(showPrice(), style: tsOverline),
            ],
          ),
          // * Renewal Bonus
          if (bonus.isNotEmpty && bonus != '0 days')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CText(
                  '+ ${bonus.toUpperCase()}',
                  style: tsOverline,
                ),
                CText('Free'.i18n.toUpperCase(), style: tsOverline),
              ],
            ),
          // * Referral bonus
          if (refCode != null && refCode!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CText(
                  '+ 1 ${'month'.i18n.toUpperCase()} ${'referral_bonus'.i18n.toUpperCase()}',
                  style: tsOverline,
                ),
                CText('free'.i18n.toUpperCase(), style: tsOverline),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CText('total'.i18n, style: tsBody1),
              CText(
                showPrice(),
                style: tsBody1.copiedWith(
                  color: pink4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const CDivider(height: 24),
        ],
      ),
    );
  }

  String showPrice() {
    if (Platform.isIOS) {
      return getPrice(plan.totalCost);
    } else {
      if (isProdPlay()) {
        return getPrice(plan.totalCost);
      }
      return plan.totalCost.split(' ').first;
    }
  }

  String getPrice(String totalCost, {bool perMonthCost = false}) {
    final appPurchase = sl<AppPurchase>();
    final appStorePrice =
        appPurchase.getPriceFromPlanId(plan.id, perMonthCost: perMonthCost);
    return appStorePrice == '' ? totalCost : appStorePrice;
  }
}
