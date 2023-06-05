import 'package:lantern/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:lantern/i18n/localization_constants.dart';
import 'package:lantern/plans/plan_details.dart';
import 'package:lantern/plans/utils.dart';

final featuresList = [
  'unlimited_data'.i18n,
  'faster_data_centers'.i18n,
  'no_logs'.i18n,
  'connect_up_to_3_devices'.i18n,
  'no_ads'.i18n,
];

class PlansPage extends StatefulWidget {
  PlansPage({Key? key}) : super(key: key);

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final bool isPro = false;

  bool isTwoYearPlan = true;

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

  @override
  Widget build(BuildContext context) {
    return FullScreenDialog(widget: sessionModel.plans(builder: (
      context,
      Iterable<PathAndValue<Plan>> plans,
      Widget? child,
    ) {
      if (plans.isEmpty) {
        return Center(
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
        );
      }

      final isFree = !isPro;
      var platinumAvailable = false;
      var isPlatinum = false;
      //final renewalText = plans.last['renewalText'];
      return StatefulBuilder(
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
                                      setState(() => isTwoYearPlan = newValue);
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
                                                CText(
                                                  '',
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
                          if (plans != null)
                            ...plans.map(
                              (plan) => PlanCard(
                                plan: plan.value,
                                isPro: isPro,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // * Footer
                  if (!isPlatinum)
                    Stack(
                      children: [
                        Container(
                          height: 40,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          color: grey1,
                          child: GestureDetector(
                            onTap: () async => await context.pushRoute(
                              ResellerCodeCheckout(isPro: isPro),
                            ),
                            child: CText(
                              'Have a Lantern Pro activation code? Click here.',
                              style: tsBody1.copiedWith(color: grey5),
                            ),
                          ), // Translations
                        ),
                        Divider(
                          color: grey1,
                          height: 2,
                        ),
                      ],
                    ),
                ])),
      );
    }));
  }
}
