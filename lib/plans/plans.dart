import 'package:lantern/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:lantern/plans/utils.dart';

final featuresList = [
  'unlimited_data'.i18n,
  'faster_data_centers'.i18n,
  'no_logs'.i18n,
  'connect_up_to_3_devices'.i18n,
  'no_ads'.i18n,
];

class PlanCard extends StatelessWidget {
  final List<Plan> plans;
  final String id;
  final bool isPro;

  const PlanCard({
    required this.plans,
    required this.id,
    required this.isPro,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedPlan = plans.firstWhere((p) => p.id == id);
    // final description = selectedPlan['description'] as String;
    final formattedPricePerYear =
        selectedPlan.totalCostBilledOneTime;
    final formattedPricePerMonth = selectedPlan.oneMonthCost;
    final isBestValue = selectedPlan.bestValue;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16.0),
      child: CInkWell(
        onTap: () async {
          final isPlayVersion = sessionModel.isPlayVersion.value ?? false;

          // * Play version
          if (isPlayVersion) {
            await sessionModel
                .submitGooglePlay(id)
                .onError((error, stackTrace) {
              // on failure
              CDialog.showError(
                context,
                error: e,
                stackTrace: stackTrace,
                description:
                    (error as PlatformException).message ?? error.toString(),
              );
            });
          } else {
            // * Proceed to our own Checkout
            await context.pushRoute(
              Checkout(
                plans: plans,
                id: id,
                isPro: isPro,
              ),
            );
          }
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Card(
              color: isBestValue ? pink1 : white,
              shadowColor: grey2,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: isBestValue ? 2.0 : 1.0,
                  color: isBestValue ? pink4 : grey2,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: isBestValue ? 3 : 0,
              child: Container(
                padding: const EdgeInsetsDirectional.only(
                  start: 24.0,
                  end: 24.0,
                  top: 12.0,
                  bottom: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // * Plan name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CText(
                          'pro_plan'.i18n,
                          style: tsSubtitle2.copiedWith(
                            color: pink3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const CAssetImage(
                          path: ImagePaths.keyboard_arrow_right,
                        )
                      ],
                    ),
                    // * Price per month
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        CText(formattedPricePerMonth, style: tsHeading1),
                        CText(' / ', style: tsBody2),
                        CText('month'.i18n, style: tsBody2),
                      ],
                    ),
                    // * Price per year
                    Row(
                      children: [
                        CText(
                          formattedPricePerYear,
                          style: tsBody2.copiedWith(color: grey5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isBestValue)
              Transform.translate(
                offset: const Offset(0.0, 10.0),
                child: Card(
                  color: yellow4,
                  shadowColor: grey2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: isBestValue ? 3 : 1,
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12.0,
                      top: 0.0,
                      end: 12.0,
                      bottom: 4.0,
                    ),
                    child: CText(
                      '${'most_popular'.i18n}!',
                      style: tsBody1,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class PlanStep extends StatelessWidget {
  final String stepNum;
  final String description;

  const PlanStep({
    Key? key,
    required this.stepNum,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.only(
            start: 12.0,
            top: 0,
            end: 12.0,
            bottom: 2.0,
          ),
          decoration: BoxDecoration(
            color: black,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: CText(
            'step_$stepNum'.i18n,
            style: tsBody1.copiedWith(color: white),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8.0),
          child: CText(description, style: tsBody1),
        )
      ],
    );
  }
}

class Upgrade extends StatefulWidget {
  Upgrade({Key? key}) : super(key: key);

  @override
  State<Upgrade> createState() => _PlansState();
}

class _PlansState extends State<Upgrade> {
  final bool isPro = false;

  bool isTwoYearPlan = true;

  @override
  Widget build(BuildContext context) {
    return sessionModel
        .plans((BuildContext context, Plans cachedPlans, Widget? child) {
      final plans = cachedPlans.plans;
      debugPrint("Plans: ${plans}");
      if (plans.isEmpty) {
        return FullScreenDialog(
          widget: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CAssetImage(
                  path: ImagePaths.error,
                  size: 100,
                  color: grey5,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.all(24.0),
                  child: CText(
                    'error_fetching_plans'.i18n,
                    style: tsBody1,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      Widget buildHeader(
        BuildContext context,
      ) {
        return Container(
          height: 90,
          child: Stack(
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
                  path: ImagePaths.lantern_pro_logotype,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      }

      // Builds the renewal text (for Pro and Platinum, inside and outside China) and the list of features (for Pro and Platinum outside China)
      Widget buildRenewalTextOrUpsell(
        BuildContext context,
        bool? platinumAvailable,
        bool? isFree,
      ) {
        // TODO: revisit
        // final renewalText = visiblePlans.last['renewalText'];
        final renewalText = '';
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // * Renewal text
              // For Pro or Platinum users: "Your membership is ending soon. Renew now and enjoy up to three months free!"
              if (renewalText != '')
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 12.0),
                  child: CText(
                    renewalText,
                    style: tsBody1,
                  ),
                ),
              // * List of features for non-China locations
              if (platinumAvailable == false)
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsetsDirectional.only(
                        bottom: 12.0,
                      ),
                      child: CDivider(),
                    ),
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

      final isFree = !isPro;
      var platinumAvailable = false;
      //final renewalText = plans.last['renewalText'];
      return FullScreenDialog(
        widget: StatefulBuilder(
          builder: (context, setState) => Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildHeader(context),
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
                            buildRenewalTextOrUpsell(
                              context,
                              platinumAvailable,
                              isFree,
                            ),
                            // * Step
                            Container(
                              padding: EdgeInsetsDirectional.only(
                                top: !platinumAvailable ? 16.0 : 0,
                                bottom: 16.0,
                              ),
                              child: PlanStep(
                                stepNum: '1',
                                description: 'choose_plan'.i18n,
                              ),
                            ),
                            if (platinumAvailable == true)
                              // * Toggle and savings banner
                              Container(
                                padding: const EdgeInsetsDirectional.only(
                                  bottom: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        end: 16.0,
                                      ),
                                      child: CText(
                                        '1y_pricing'.i18n,
                                        style: isTwoYearPlan
                                            ? tsBody1.copiedWith(color: grey5)
                                            : tsBody1,
                                      ),
                                    ),
                                    FlutterSwitch(
                                      width: 44.0,
                                      height: 24.0,
                                      valueFontSize: 12.0,
                                      padding: 2,
                                      toggleSize: 18.0,
                                      value: isTwoYearPlan,
                                      activeColor: indicatorGreen,
                                      inactiveColor: indicatorGreen,
                                      onToggle: (bool newValue) {
                                        setState(
                                            () => isTwoYearPlan = newValue);
                                      },
                                    ),
                                    // * Savings banner
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        start: 16.0,
                                      ),
                                      child: Stack(
                                        children: [
                                          Transform.translate(
                                            offset: const Offset(30.0, -25.0),
                                            child: const CAssetImage(
                                              path: ImagePaths.savings_arrow,
                                            ),
                                          ),
                                          Transform.translate(
                                            offset: const Offset(65.0, -30.0),
                                            child: Transform.rotate(
                                              angle: 0.1 * pi,
                                              child: Stack(
                                                children: [
                                                  CText('',
                                                    style: tsBody1.copiedWith(
                                                      color: pink4,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          CText(
                                            '2y_pricing'.i18n,
                                            style: isTwoYearPlan
                                                ? tsBody1
                                                : tsBody1.copiedWith(
                                                    color: grey5,
                                                  ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // * Card
                            if (plans != null) ...plans.map(
                              (plan) => PlanCard(
                                plans: plans,
                                id: plan.id,
                                //platinumAvailable: platinumAvailable,
                                isPro: isPro,
                                //isPlatinum: isPlatinum,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ])),
        ),
      );
    });
  }
}
