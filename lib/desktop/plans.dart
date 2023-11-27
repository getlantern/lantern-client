import 'package:lantern/common/common.dart';
import 'package:lantern/plans/plan_details.dart';
import 'package:lantern/plans/utils.dart';
import 'package:lantern/desktop/ffi.dart';
import 'dart:ffi' as ffi; // For FFI
import 'package:ffi/ffi.dart';
import 'package:ffi/src/utf8.dart';
import 'dart:convert';
import 'package:lantern/i18n/i18n.dart';
import 'package:fixnum/fixnum.dart';
import 'package:intl/intl.dart';

@RoutePage(name: "PlansDesktop")
class PlansDesktop extends StatefulWidget {
  PlansDesktop({
    Key? key,
  }) : super(key: key);

  @override
  State<PlansDesktop> createState() => _PlansDesktopState();
}

class _PlansDesktopState extends State<PlansDesktop>
    with SingleTickerProviderStateMixin {
  List<dynamic> plans = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPlans();
    });
  }

  void fetchPlans() async {
    var result = "{}";
    final formatCurrency = new NumberFormat.simpleCurrency();
    setState(() {
      var resp = jsonDecode(result) as List<dynamic>;
      print("Resp is ${resp}");
      for (var item in resp) {
        var plan = Plan();
        var usdPrice = item["usdPrice"];
        plan.id = item["id"];
        plan.description = item["description"];
        plan.oneMonthCost = formatCurrency.format(item["expectedMonthlyPrice"]["usd"]/100).toString();
        plan.totalCost = formatCurrency.format(item["usdPrice"]/100).toString();
        plan.totalCostBilledOneTime = formatCurrency.format(item["usdPrice"]/100).toString() + ' ' + 'billed_one_time'.i18n;
        plan.bestValue = item["bestValue"] ?? false;
        plan.usdPrice = Int64(item["usdPrice"]);
        plans.add(plan);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var proUser = false;
    return FullScreenDialog(
        widget: StatefulBuilder(
      builder: (context, setState) => Container(
        color: white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.only(
                      top: 10,
                      bottom: 10,
                      start: 32,
                      end: 16,
                    ),
                    color: white,
                    child: Row(
                      children: [
                        Container(
                          child: const CAssetImage(
                            path: ImagePaths.lantern_pro_logotype,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: mirrorLTR(
                            context: context,
                            child: CAssetImage(
                              path: ImagePaths.cancel,
                              color: black,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, null),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: white,
                    padding: const EdgeInsetsDirectional.only(
                      start: 24,
                      end: 24,
                    ),
                    child: Column(
                      children: [
                        // * Renewal text or upsell
                        if (proUser && plans.last.renewalText != '')
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              bottom: 12.0,
                            ),
                            child: CText(
                              plans.last.renewalText,
                              style: tsBody1,
                            ),
                          ),
                        const Padding(
                          padding: EdgeInsetsDirectional.only(
                            bottom: 8.0,
                          ),
                          child: CDivider(),
                        ),
                        ...featuresList.map(
                          (feature) => Container(
                            padding: const EdgeInsetsDirectional.only(
                              start: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const CAssetImage(
                                  path: ImagePaths.check_green_large,
                                  size: 24,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 4.0,
                                    bottom: 4.0,
                                  ),
                                  child: CText(
                                    feature,
                                    textAlign: TextAlign.center,
                                    style: tsBody1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const CDivider(height: 24),
                      ],
                    ),
                  ),
                  // * Step
                  Container(
                    color: white,
                    padding: const EdgeInsetsDirectional.only(
                      top: 16.0,
                      bottom: 16.0,
                      start: 32.0,
                      end: 32.0,
                    ),
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(start: 4.0),
                      child: PlanStep(
                        stepNum: '1',
                        description: 'choose_plan'.i18n,
                      ),
                    ),
                  ),
                  // * Card
                  ...plans.toList().reversed.map(
                        (plan) => Container(
                          color: white,
                          padding: const EdgeInsetsDirectional.only(
                            start: 32.0,
                            end: 32.0,
                          ),
                          child: PlanCard(
                            plan: plan as Plan,
                            isPro: proUser,
                          ),
                        ),
                      ),
                ],
              ),
            ),
            // * Footer
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 24.0),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1.0, color: grey3),
                  ),
                  color: grey1,
                ),
                child: GestureDetector(
                  onTap: () async => await context.pushRoute(
                    ResellerCodeCheckout(isPro: proUser),
                  ),
                  child: CText(
                    'Have a Lantern Pro activation code? Click here.',
                    style: tsBody1.copiedWith(color: grey5),
                  ),
                ), // Translations
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
