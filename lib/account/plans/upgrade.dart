import 'package:lantern/account/plans/plan_card.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/common/common.dart';

import 'purchase_constants.dart';
import 'plan_utils.dart';

class Upgrade extends StatelessWidget {
  final bool isPro;

  Upgrade({
    Key? key,
    required this.isPro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sessionModel.getCachedPlans((context, cachedPlans, child) {
      final plans = formatCachedPlans(cachedPlans);
      final platinumAvailable = isPlatinumAvailable(cachedPlans);
      // * Error screen if plans are empty
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
      var visiblePlans =
          determineVisiblePlans(isTwoYearPlan, plans, platinumAvailable);
      final isFree = !isPro;
      final showBanner = determineBannerContent(isFree, plans);

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
                                    setState(() => isTwoYearPlan = newValue);
                                    setState(
                                      () =>
                                          visiblePlans = determineVisiblePlans(
                                        newValue,
                                        plans,
                                        platinumAvailable,
                                      ),
                                    );
                                  },
                                ),
                                // * Savings banner
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 16.0,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (showBanner != null)
                                        Transform.translate(
                                          offset: const Offset(30.0, -25.0),
                                          child: const CAssetImage(
                                            path: ImagePaths.savings_arrow,
                                          ),
                                        ),
                                      if (showBanner != null)
                                        Transform.translate(
                                          offset: const Offset(65.0, -30.0),
                                          child: Transform.rotate(
                                            angle: 0.1 * pi,
                                            child: Stack(
                                              children: [
                                                CText(
                                                  determineBannerContent(
                                                    isFree,
                                                    plans,
                                                  )!
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // * Footer
                sessionModel.getCachedUserLevel((context, userLevel, child) {
                  final isPlatinum = isUserLevelPlatinum(userLevel);
                  return (isPlatinum)
                      ? Container()
                      : Stack(
                          children: [
                            Container(
                              height: 40,
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              color: grey2,
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
                            Divider(
                              color: grey1,
                              height: 2,
                            ),
                          ],
                        );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  // * Only visible in China
  String? determineBannerContent(
    bool isFree,
    List<Map<String, dynamic>> plans,
  ) {
    // for the savings banner we only compare 1y Platinum to 2y Platinum
    final platinumPlans =
        plans.where((element) => element['level'] == 'platinum');

    if (platinumPlans.isEmpty) return '';

    final bannerSavings = determineSavings(platinumPlans);
    final bannerRenewalBonus = determineBannerRenewalBonus(platinumPlans);
    if (bannerSavings == '0' || bannerRenewalBonus == '0 days') return null;
    return isFree == true || bannerSavings == '0' || bannerRenewalBonus == '0'
        ?
        // Free user who is upgrading => fixed %
        'Save $bannerSavings%'
        : '+' + bannerRenewalBonus;
  }

  // * Only visible in China
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

  // * Only visible in China
  // For Pro or Platinum users in China, it displays a "+3 months" text
  String determineBannerRenewalBonus(Iterable platinumPlans) {
    var bannerRenewalBonus = platinumPlans.firstWhere(
      (p) => (p['id'] as String).startsWith('2y'),
    )['formattedBonus'];
    return bannerRenewalBonus;
  }

  // Takes toggle state into consideration to determine which plans are displayed
  // If no toggle visible (= Global plans), then no filtering occurs.
  List<Map<String, dynamic>> determineVisiblePlans(
    bool isTwoYearPlan,
    List<Map<String, dynamic>> plans,
    bool platinumAvailable,
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
            (a['bestValue'] as bool) ? 1 : 0, // sort bestValue plan to bottom
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
          // * Renewal text
          // For Pro or Platinum users: "Your membership is ending soon. Renew now and enjoy up to three months free!"
          sessionModel.getRenewalText(
            (context, renewalText, child) => renewalText.isNotEmpty
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 12.0),
                    child: CText(
                      renewalText,
                      style: tsBody1,
                    ),
                  )
                : const SizedBox(),
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

  Widget buildHeader(
    BuildContext context,
    bool? platinumAvailable,
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
