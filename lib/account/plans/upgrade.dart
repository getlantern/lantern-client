import 'package:lantern/account/plans/plan_card.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/common/common.dart';

import 'constants.dart';

class Upgrade extends StatelessWidget {
  Upgrade({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isTwoYearPlan = true;
    var availablePlans = determineAvailablePlans(isTwoYearPlan);
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
                        padding: const EdgeInsetsDirectional.only(
                          top: 16.0,
                          bottom: 16.0,
                        ),
                        child: const PlanStep(
                          stepNum: '1',
                          description: 'Choose Plan', // TODO: translations
                        ),
                      ),
                      if (isCN == true)
                        // * Toggle
                        Container(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: 16,
                          ),
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
                                  setState(
                                    () => availablePlans =
                                        determineAvailablePlans(newValue),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 16.0,
                                ),
                                child: Stack(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(80.0, -25.0),
                                      child: const CAssetImage(
                                        path: ImagePaths.savings_arrow,
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(115.0, -30.0),
                                      child: Transform.rotate(
                                        angle: 0.1 * pi,
                                        child: Stack(
                                          children: [
                                            CText(
                                              determineSavingsOrExtraMonths()
                                                  .toUpperCase(),
                                              style: tsBody1.copiedWith(
                                                color: pink4,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    CText(
                                      '2 year pricing',
                                      style: isTwoYearPlan
                                          ? tsBody1
                                          : tsBody1.copiedWith(color: grey5),
                                    )
                                  ],
                                ), // TODO: translations
                              ),
                            ],
                          ),
                        ),
                      // * Card
                      ...availablePlans.map(
                        (plan) => PlanCard(
                          id: plan['id'] as String,
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
                    ActivationCodeCheckout(),
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

  String determineSavingsOrExtraMonths() {
    // TODO - this has to do with expiration status
    const savingsPercentage = '34 %';
    return isFree == true
        ?
        // Free user who is upgrading => fixed %
        'Save $savingsPercentage'
        :
        // Pro user who is upgrading
        // 1. in advance => + 3 months
        // 2. upon expiry => + 3 months
        // 3. after having recently expired => + 45 days
        '+ 3 months';
  }

  String determineExpiryText() {
    // TODO: depends on expiry status
    return 'This is a Pro or Platinum user so they should have some text here';
  }

  List<Map<String, Object>> determineAvailablePlans(bool isTwoYearPlan) {
    // if we are not in China, we only have two available plans which we both want to render
    if (!isCN) return plans;

    // we are in China, determine 2 out of 4 plans depending on where the toggle is set
    return plans
        .where(
          (plan) =>
              plan['id'].toString().startsWith(isTwoYearPlan ? '2y' : '1y'),
        )
        .toList();
  }

  Widget buildRenewalTextOrUpsell(
    BuildContext context,
    bool? isCN,
    bool? isFree,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: translations
          if (isFree == false)
            CText(
              determineExpiryText(),
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
            child: CAssetImage(
              path: isCN == true
                  ? ImagePaths.lantern_logotype
                  : ImagePaths.lantern_pro_logotype,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
