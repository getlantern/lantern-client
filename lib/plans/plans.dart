import 'package:lantern/common/common.dart';

class PlanCard extends StatelessWidget {
  final List<Map<String, dynamic>> plans;
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
    final selectedPlan = plans.firstWhere((p) => p['id'] == id);
    // final description = selectedPlan['description'] as String;
    final formattedPricePerYear =
        selectedPlan['totalCostBilledOneTime'].toString();
    final formattedPricePerMonth = selectedPlan['oneMonthCost'].toString();
    final isBestValue = selectedPlan['bestValue'] as bool;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16.0),
      child: CInkWell(
        onTap: () async {
          final isPlayVersion = await sessionModel.getPlayVersion();

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
