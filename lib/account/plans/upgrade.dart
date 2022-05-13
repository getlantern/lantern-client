import 'package:lantern/account/plans/plan_card.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/common/common.dart';

import 'purchase_constants.dart';
import 'purchase_utils.dart';

class Upgrade extends StatelessWidget {
  final bool platinumAvailable;
  final bool isPlatinum;
  final bool isPro;

  Upgrade({
    Key? key,
    required this.platinumAvailable,
    required this.isPlatinum,
    required this.isPro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sessionModel.getCachedPlans((context, cachedPlans, child) {
      return sessionModel.getCachedPlans((context, cachedPlans, child) {
        final plans = formatCachedPlans(cachedPlans);
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

        var isTwoYearPlan = true; // Toggle is by default to 2 years
        var visiblePlans = determineVisiblePlans(isTwoYearPlan, plans);
        final isFree = (isPro == false) && (isPlatinum == false);

        return FullScreenDialog(
          widget: StatefulBuilder(
            builder: (context, setState) => Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // * Logotype + X button
                  buildHeader(context, platinumAvailable),
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
                          buildRenewalTextOrUpsell(
                            context,
                            platinumAvailable,
                            isFree,
                            visiblePlans,
                          ),
                          // * Step
                          Container(
                            padding: const EdgeInsetsDirectional.only(
                              top: 16.0,
                              bottom: 16.0,
                            ),
                            child: PlanStep(
                              stepNum: '1',
                              description: 'choose_plan'.i18n,
                            ),
                          ),
                          if (platinumAvailable == true)
                            // * Toggle
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
                                    onToggle: (bool newValue) {
                                      setState(() => isTwoYearPlan = newValue);
                                      setState(
                                        () => visiblePlans =
                                            determineVisiblePlans(
                                          newValue,
                                          plans,
                                        ),
                                      );
                                    },
                                  ),
                                  if (isTwoYearPlan)
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
                                                    determineBannerContent(
                                                      isFree,
                                                      plans,
                                                    ).toUpperCase(),
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
                          ...visiblePlans.map(
                            (plan) => PlanCard(
                              plans: plans,
                              id: plan['id'] as String,
                              platinumAvailable: platinumAvailable,
                              isPro: isPro,
                              isPlatinum: isPlatinum,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // * Footer
                  if (!isPlatinum)
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      color: grey3,
                      child: GestureDetector(
                        onTap: () async => await context.pushRoute(
                          ResellerCodeCheckout(isPro: isPro),
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
      });
    });
  }

  // Only visible in China
  String determineBannerContent(
    bool isFree,
    List<Map<String, Object>> plans,
  ) {
    // for the savings banner we only compare 1y Platinum to 2y Platinum
    final platinumPlans =
        plans.where((element) => element['level'] == 'platinum');

    if (platinumPlans.isEmpty) return '';

    final bannerSavings = determineSavings(platinumPlans);
    final bannerRenewalBonus = '+' + determineBannerRenewalBonus(platinumPlans);
    return isFree == true
        ?
        // Free user who is upgrading => fixed %
        'Save $bannerSavings%'
        : bannerRenewalBonus;
  }

  // Only visible in China
  // For Free users in China, it displays a renewal bonus %
  // To facilitate our lives we only compare Platinum plans to each other
  // (the result % is higher than comparing Pro plans to each other)
  String determineSavings(Iterable platinumPlans) {
    final platinumPlanPrices =
        platinumPlans.map((pr) => (pr['usdPrice'] as num)).toList();
    final discount =
        ((platinumPlanPrices.reduce(min) - platinumPlanPrices.reduce(max) / 2) /
                platinumPlanPrices.reduce(min)) *
            100;
    return discount.toInt().toString();
  }

  // Only visible in China
  // For Pro or Platinum users in China, it displays a "+3 months" text
  String determineBannerRenewalBonus(Iterable platinumPlans) {
    // TODO: waiting for feedback on how to handle long strings
    var bannerRenewalBonus = platinumPlans.firstWhere(
      (p) => (p['id'] as String).startsWith('2y'),
    )['formattedBonus'];
    return bannerRenewalBonus;
  }

  // Takes toggle state into consideration to determine which plans are displayed
  // If no toggle visible (= Global plans), then no filtering occurs.
  List<Map<String, Object>> determineVisiblePlans(
    bool isTwoYearPlan,
    List<Map<String, Object>> plans,
  ) {
    // if we are not in China, we only have two available plans which we both want to render
    if (!platinumAvailable) return plans;

    // we are in China, determine 2 out of 4 plans depending on where the toggle is set
    return plans
        .where(
          (plan) =>
              plan['id'].toString().startsWith(isTwoYearPlan ? '2y' : '1y'),
        )
        .toList()
      ..sort(
        (a, b) =>
            (a['bestValue'] as bool) ? 0 : 1, // sort bestValue plan to top
      );
  }

  // Builds the renewal text (for Pro and Platinum, inside and outside China) and the list of features (for Pro and Platinum outside China)
  Widget buildRenewalTextOrUpsell(
    BuildContext context,
    bool? platinumAvailable,
    bool? isFree,
    Iterable visiblePlans,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Renewal text
          // For Pro or Platinum users: "Your membership is ending soon. Renew now and enjoy up to three months free!"
          if (isFree == false)
            CText(
              visiblePlans.last['renewalText'],
              style: tsBody1,
            ),
          // List of features for non-China locations
          if (platinumAvailable == false)
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

  Widget buildHeader(
    BuildContext context,
    bool? platinumAvailable,
  ) {
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
              path: platinumAvailable == true
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
