import 'package:lantern/account/plans/plan_card.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/common/common.dart';

class Upgrade extends StatelessWidget {
  final bool? isCN;
  final bool? isFree;
  final bool? isPro;
  final bool? isPlatinum;

  Upgrade({this.isCN, Key? key, this.isFree, this.isPro, this.isPlatinum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isTwoYearPlan = true;
    // TODO: temporary
    const plans = [
      {
        'planName': 'Pro',
        'currency': '\$',
        'pricePerMonth': '3.20',
        'pricePerYear': '30',
        'isBestValue': false,
      },
      {
        'planName': 'Platinum',
        'currency': '\$',
        'pricePerMonth': '4.30',
        'pricePerYear': '50',
        'isBestValue': true,
      },
    ];
    return FullScreenDialog(
      widget: StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // * Logotype + X button
              buildHeader(context, isCN),
              // * Body
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: 32,
                    end: 32,
                    bottom: 32,
                  ),
                  child: Column(
                    children: [
                      // * Renewal text or upsell
                      buildRenewalTextOrUpsell(context, isCN, isFree),
                      // * Step
                      Container(
                        padding:
                            const EdgeInsetsDirectional.only(top: 8, bottom: 8),
                        child: const PlanStep(
                          stepNum: '1',
                          description: 'Choose Plan', // TODO: translations
                        ),
                      ),
                      // * Toggle
                      Container(
                        padding:
                            const EdgeInsetsDirectional.only(top: 8, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(end: 16.0),
                              child: CText(
                                '1 year pricing',
                                style: isTwoYearPlan
                                    ? tsBody1.copiedWith(color: grey5)
                                    : tsBody1,
                              ), // TODO: translations
                            ),
                            FlutterSwitch(
                              width: 44.0,
                              height: 24.0,
                              valueFontSize: 12.0,
                              padding: 2,
                              toggleSize: 18.0,
                              value: isTwoYearPlan,
                              activeColor: indicatorGreen,
                              onToggle: (bool newValue) {
                                setState(() => isTwoYearPlan = newValue);
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 16.0),
                              child: CText(
                                '2 year pricing',
                                style: isTwoYearPlan
                                    ? tsBody1
                                    : tsBody1.copiedWith(color: grey5),
                              ), // TODO: translations
                            ),
                            // TODO: Add saving % component
                          ],
                        ),
                      ),
                      // * Card
                      ...plans.map(
                        (plan) => PlanCard(
                          // TODO: temp workaround
                          isCN: isCN,
                          isFree: isFree,
                          isPro: isPro,
                          isPlatinum: isPlatinum,
                          // TODO: build isTwoYears logic here
                          planName: plan['planName'] as String,
                          currency: plan['currency'] as String,
                          pricePerMonth: plan['pricePerMonth'] as String,
                          pricePerYear: plan['pricePerYear'] as String,
                          isBestValue: plan['isBestValue'] as bool,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // * Footer
              Container(
                height: 40,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                color: grey3,
                child: GestureDetector(
                  onTap: () async => await context.pushRoute(
                    ActivationCodeCheckout(
                      isCN: isCN,
                      isFree: isFree,
                      isPlatinum: isPlatinum,
                      isPro: isPro,
                    ),
                  ),
                  child: CText(
                    'Have a Lantern Pro activation code? Click here.',
                    style: tsBody1,
                  ),
                ), // Translations
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRenewalTextOrUpsell(
      BuildContext context, bool? isCN, bool? isFree) {
    const featuresList = [
      // TODO: translations
      'Unlimited data',
      'Faster data centers',
      'No logs',
      'Connect up to 3 devices',
      'No Ads',
    ];
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: translations
          if (isFree == false)
            CText(
              'This is a Pro or Platinum user so they should have some text here',
              style: tsBody1,
            ),
          if (isCN == false)
            Column(
              children: [
                const CDivider(height: 24),
                ...featuresList.map(
                  (feature) => Row(
                    children: [
                      const CAssetImage(
                        path: ImagePaths.check_green_large,
                        size: 24,
                      ),
                      CText(feature, style: tsBody1),
                    ],
                  ),
                ),
                const CDivider(height: 24),
              ],
            )
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context, bool? isCN) {
    return Container(
      height: 100,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            padding: const EdgeInsetsDirectional.only(top: 25),
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: mirrorLTR(
                context: context,
                child: CAssetImage(
                  path: ImagePaths.cancel,
                  color: black,
                ),
              ),
              onPressed: () => Navigator.pop(context, null),
            ),
          ),
          Container(
            padding: const EdgeInsetsDirectional.only(top: 25, start: 32),
            alignment: Alignment.centerLeft,
            child: const CAssetImage(
              // TODO: this depends on isCN
              path: ImagePaths.lantern_logotype,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
