import 'package:lantern/common/common.dart';

class PriceSummary extends StatelessWidget {
  final List<Map<String, Object>> plans;
  final String id;
  final String? refCode;
  final bool isPro;
  final bool isPlatinum;

  const PriceSummary({
    Key? key,
    required this.plans,
    required this.id,
    required this.isPro,
    required this.isPlatinum,
    this.refCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedPlan = plans.firstWhere((p) => p['id'] == id);
    final formattedPricePerYear =
        selectedPlan['totalCost'].toString().split(' ').first;
    final refCodeBonus = 'bonus from referral code';
    final bonus = '+ ' + selectedPlan['formattedBonus'].toString();
    return Container(
      padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          const CDivider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CText('plan_type'.i18n.toUpperCase(), style: tsOverline),
              CText(formattedPricePerYear, style: tsOverline),
            ],
          ),
          if (isPro != false || isPlatinum != false)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TODO: calculate credit months text
                CText(
                  bonus.toUpperCase(),
                  style: tsOverline,
                ),
                CText('Free'.i18n, style: tsOverline),
              ],
            ),
          if (refCode != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TODO: calculate text
                CText(
                  refCodeBonus.toUpperCase(),
                  style: tsOverline,
                ),
                CText('Free'.i18n, style: tsOverline),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CText('Total'.i18n, style: tsBody1),
              CText(
                formattedPricePerYear,
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
}
