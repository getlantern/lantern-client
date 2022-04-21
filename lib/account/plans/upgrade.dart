import 'package:lantern/account/plans/plan_card.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/common/common.dart';

class Upgrade extends StatelessWidget {
  Upgrade({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isTwoYearPlan = true;
    return FullScreenDialog(
      widget: StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // * Logotype + X button
              buildHeader(context),
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
                      buildRenewalTextOrUpsell(context),
                      // * Step
                      Container(
                        padding:
                            const EdgeInsetsDirectional.only(top: 8, bottom: 8),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        child: const PlanStep(
                          stepNum: '1',
                          description: 'Choose Plan', // TODO: translations
                        ),
                      ),
                      // * Toggle
                      Container(
                        padding:
                            const EdgeInsetsDirectional.only(top: 8, bottom: 8),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
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
                      Flexible(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: PlanCard()),
                      ),
                      // * Card
                      Flexible(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: PlanCard()),
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
                child: Text('Have a Lantern Pro activation code? Click here'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRenewalTextOrUpsell(BuildContext context) {
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
          CText('Bla bla text if we are renewing bla bla', style: tsBody1),
          // TODO: only if !isCN
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

  Widget buildHeader(BuildContext context) {
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
              // TODO: this should respond to isCN
              path: ImagePaths.lantern_logotype,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
