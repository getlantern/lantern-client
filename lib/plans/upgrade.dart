import 'package:lantern/common/common.dart';
import 'package:lantern/plans/plans.dart';
import 'package:lantern/plans/utils.dart';

final featuresList = [
  'unlimited_data'.i18n,
  'faster_data_centers'.i18n,
  'no_logs'.i18n,
  'connect_up_to_3_devices'.i18n,
  'no_ads'.i18n,
];

class Upgrade extends StatelessWidget {
  final bool isPro;

  Upgrade({
    Key? key,
    required this.isPro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sessionModel.getPlans((context, cachedPlans, child) {
      debugPrint('Plans: ${cachedPlans}');
      final plans = formatPlans(cachedPlans);
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

      final isFree = !isPro;
      final renewalText = plans.last['renewalText'];
      return FullScreenDialog(
        widget: StatefulBuilder(
          builder: (context, setState) => Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
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
                        padding: const EdgeInsetsDirectional.only(
                            top: 25, start: 32),
                        alignment: Alignment.centerLeft,
                        child: CAssetImage(
                          path: ImagePaths.lantern_pro_logotype,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
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
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // * Renewal text
                              if (renewalText != '')
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      bottom: 12.0),
                                  child: CText(
                                    renewalText,
                                    style: tsBody1,
                                  ),
                                ),
                              // * List of features for non-China locations
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
                        ),
                        // * Step
                        Container(
                          padding: EdgeInsetsDirectional.only(
                            top: 16.0,
                            bottom: 16.0,
                          ),
                          child: PlanStep(
                            stepNum: '1',
                            description: 'choose_plan'.i18n,
                          ),
                        ),
                        // * Card
                        ...plans.map(
                          (plan) => PlanCard(
                            plans: plans,
                            id: plan['id'] as String,
                            isPro: isPro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // * Footer
                Stack(
                  children: [
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      color: grey2,
                      child: GestureDetector(
                        onTap: () async => await context.pushRoute(
                          ResellerCheckout(isPro: isPro),
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
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
