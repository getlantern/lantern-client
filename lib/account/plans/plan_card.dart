import 'package:lantern/common/common.dart';

import 'purchase_constants.dart';

class PlanCard extends StatelessWidget {
  final List<Map<String, dynamic>> plans;
  final String id;
  final bool isPro;
  final bool platinumAvailable;
  final bool isPlatinum;

  const PlanCard({
    required this.plans,
    required this.id,
    required this.isPro,
    required this.platinumAvailable,
    required this.isPlatinum,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final plan = plans.firstWhere((p) => p['id'] == id);
    final planName = platinumAvailable
        ? '${id.contains('platinum') ? 'Platinum' : 'Pro'} Plan'.i18n
        : (plan['id'] as String).contains('2y')
            ? 'Two Years Pro'.i18n
            : 'One Year Pro'.i18n;
    ;
    final formattedPricePerYear = plan['totalCostBilledOneTime'].toString();
    final formattedPricePerMonth = plan['oneMonthCost'].toString();
    final isBestValue = plan['bestValue'] as bool;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16.0),
      child: CInkWell(
        onTap: () async {
          final isPlayVersion = await sessionModel.getPlayVersion();

          // * Play version
          if (isPlayVersion && !platinumAvailable) {
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
                isPlatinum: isPlatinum,
                platinumAvailable: platinumAvailable,
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
                          planName,
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
                    // * Plan details if in China
                    if (platinumAvailable == true)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...chinaPlanDetails[isBestValue ? 1 : 0].map(
                              (d) => Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: 8.0,
                                    ),
                                    child: CAssetImage(
                                      path: isBestValue
                                          ? d == chinaPlanDetails[1].first
                                              ? ImagePaths.check_black
                                              : ImagePaths.add
                                          : ImagePaths.check_black,
                                      size: 16,
                                    ),
                                  ),
                                  CText(d, style: tsBody1),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
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
