import 'package:lantern/common/common.dart';

class PlanCard extends StatelessWidget {
  final bool? isCN;
  final bool? isFree;
  final bool? isPro;
  final bool? isPlatinum;
  final String planName;
  final String currency;
  final String pricePerMonth;
  final String pricePerYear;
  final bool isBestValue;
  final String? percentSavings;

  const PlanCard({
    this.isCN,
    Key? key,
    this.isFree,
    this.isPro,
    this.isPlatinum,
    required this.planName,
    required this.currency,
    required this.pricePerMonth,
    required this.pricePerYear,
    required this.isBestValue,
    this.percentSavings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const chinaPlanDetails = [
      [
        'Unlimited data',
        'No logs',
        'Connect up to 3 devices',
      ],
      [
        'Everything included in Pro',
        'Faster Data Centers',
        'Dedicated Line',
        'Increased Reliability',
      ]
    ];

    return CInkWell(
      onTap: () async {
        // TODO: select plan
        // TODO: show next step
        // TODO: we might not need isCN here
        await context.pushRoute(
          Checkout(
            // TODO: temp workaround
            isCN: isCN,
            isFree: isFree,
            isPro: isPro,
            isPlatinum: isPlatinum,
          ),
        );
      },
      child: Card(
        color: isBestValue ? pink1 : white,
        shadowColor: grey2,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 2.0,
            color: isBestValue ? pink4 : grey2,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: isBestValue ? 3 : 1,
        child: Container(
          padding: const EdgeInsetsDirectional.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // * Plan name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CText(
                    planName,
                    style: tsSubtitle2.copiedWith(
                      color: pink3,
                    ),
                  ),
                  const CAssetImage(
                    path: ImagePaths.keyboard_arrow_right,
                  )
                ],
              ),
              const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
              // * Price per month
              Row(
                children: [
                  CText('$currency$pricePerMonth', style: tsSubtitle1),
                  // TODO: translation
                  CText(' / month', style: tsBody1),
                ],
              ),
              // * Price per year
              Row(
                children: [
                  // TODO: translation
                  CText(
                    '$currency$pricePerYear billed one time',
                    style: tsBody2.copiedWith(color: grey5),
                  ),
                ],
              ),
              // * Plan details if in China
              if (isCN == true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsetsDirectional.only(top: 6)),
                    // TODO: add icons
                    ...chinaPlanDetails[isBestValue ? 1 : 0]
                        .map((d) => CText('+ $d', style: tsBody1))
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
