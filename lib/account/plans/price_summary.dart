import 'package:lantern/common/common.dart';

import 'constants.dart';

class PriceSummary extends StatelessWidget {
  final String id;

  const PriceSummary({
    Key? key,
    required this.id,
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
                // TODO: fetch from server
                CText(
                  'This is a Pro or Platinum user so here is some credit'
                      .toUpperCase(),
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
