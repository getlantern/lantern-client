import 'package:lantern/common/common.dart';
import 'package:lantern/common/ui/app_loading_dialog.dart';
import 'package:lantern/plans/feature_list.dart';
import 'package:lantern/plans/plan_details.dart';
import 'package:lantern/plans/utils.dart';

@RoutePage(name: "PlansPage")
class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FullScreenDialog(
      bgColor: white,
      widget: sessionModel
          .proUser((BuildContext context, bool proUser, Widget? child) {
        return sessionModel.plans(
          builder: (
            context,
            Iterable<PathAndValue<Plan>> plans,
            Widget? child,
          ) {
            if (plans.isEmpty) {
              // show user option to retry
              return RetryWidget(onRetryTap: () => onRetryTap(context));
            }
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildHeader(context),
                      Container(
                        color: white,
                        padding: const EdgeInsetsDirectional.only(
                          start: 24,
                          end: 24,
                        ),
                        child: Column(
                          children: [
                            // * Renewal text or upsell
                            if (plans.last.value.renewalText != '')
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  bottom: 12.0,
                                ),
                                child: CText(
                                  plans.last.value.renewalText,
                                  style: tsBody1,
                                ),
                              ),
                            const Padding(
                              padding: EdgeInsetsDirectional.only(
                                bottom: 8.0,
                              ),
                              child: CDivider(),
                            ),
                            FeatureList(),
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
                                plan: plan.value,
                                isPro: proUser,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                _buildFooter(context, proUser),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.only(
        top: 10,
        bottom: 10,
        start: 32,
        end: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CAssetImage(
            path: ImagePaths.lantern_pro_logotype,
            size: 20,
          ),
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
    );
  }

  Widget _buildFooter(BuildContext context, bool proUser) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
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
        child: Text(
          'Have a Lantern Pro activation code? Click here.',
          style: tsBody1.copiedWith(color: grey5),
        ),
      ), // Translations
    );
  }

  // class methods

  Future<void> onRetryTap(BuildContext context) async {
    try {
      AppLoadingDialog.showLoadingDialog(context);
      await sessionModel.updatePaymentPlans();
      AppLoadingDialog.dismissLoadingDialog(context);
    } catch (e, stackTrace) {
      AppLoadingDialog.dismissLoadingDialog(context);
      showError(context, error: e, stackTrace: stackTrace);
    }
  }
}
