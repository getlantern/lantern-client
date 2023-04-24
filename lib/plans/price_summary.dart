import 'package:lantern/common/common.dart';

class PriceSummary extends StatelessWidget {
  final List<Map<String, dynamic>> plans;
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
    final description = selectedPlan['description'];
    final formattedPricePerYear =
        selectedPlan['totalCost'].toString().split(' ').first;
    final bonus = selectedPlan['formattedBonus'].toString();
    return Container(
      padding: const EdgeInsetsDirectional.only(top: 8.0),
      child: Column(
        children: [
          const CDivider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CText(description.toUpperCase(), style: tsOverline),
              CText(formattedPricePerYear, style: tsOverline),
            ],
          ),
          // * Renewal Bonus
          if (bonus != '0 days') // TODO: hacky
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
                  '+ 1 ${'month'.i18n.toUpperCase()} ${'referral bonus'.i18n.toUpperCase()}',
                  style: tsOverline,
                ),
                CText('Free'.i18n.toUpperCase(), style: tsOverline),
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