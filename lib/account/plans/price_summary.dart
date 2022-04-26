import 'package:lantern/common/common.dart';

class PriceSummary extends StatelessWidget {
  final bool? isCN;
  final bool? isFree;
  final bool? isPro;
  final bool? isPlatinum;
  final String price;

  const PriceSummary({
    Key? key,
    this.isCN,
    this.isFree,
    this.isPro,
    this.isPlatinum,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          const CDivider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TODO: translations
              CText('Plan type'.toUpperCase(), style: tsOverline),
              CText(price, style: tsOverline),
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
                price,
                style: tsBody1.copiedWith(color: pink4),
              ),
            ],
          ),
          const CDivider(height: 24),
        ],
      ),
    );
  }
}
