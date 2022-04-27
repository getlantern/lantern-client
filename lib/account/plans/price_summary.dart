import 'package:lantern/common/common.dart';

import 'constants.dart';

class PriceSummary extends StatelessWidget {
  final String id;
  final String? refCode;

  const PriceSummary({
    Key? key,
    required this.id,
    this.refCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedPlan = plans.firstWhere((p) => p['id'] == id);
    final price = selectedPlan['pricePerYear'] as String;
    final currency = selectedPlan['currency'] as String;
    return Container(
      padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          const CDivider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TODO: translations
              CText('Plan type'.toUpperCase(), style: tsOverline),
              CText(currency + price, style: tsOverline),
            ],
          ),
          if (isPro != false || isPlatinum != false)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TODO: translations
                CText(
                  'X Credit months and X credit days'.toUpperCase(),
                  style: tsOverline,
                ),
                // TODO: translations
                CText('Free', style: tsOverline),
              ],
            ),
          if (refCode != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TODO: translations
                CText(
                  '1 month referral bonus'.toUpperCase(),
                  style: tsOverline,
                ),
                // TODO: translations
                CText('Free', style: tsOverline),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TODO: translations
              CText('Total', style: tsBody1),
              CText(
                currency + price,
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
