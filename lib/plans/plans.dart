import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/ui/app_loading_dialog.dart';
import 'package:lantern/plans/feature_list.dart';
import 'package:lantern/plans/plan_details.dart';
import 'package:lantern/plans/utils.dart';
import 'package:lantern/replica/common.dart';

import '../core/purchase/app_purchase.dart';

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
                      FutureBuilder<bool>(
                        future: showRestorePurchaseButton(proUser),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () => restorePurchases(context),
                                  style: TextButton.styleFrom(
                                    foregroundColor: pink5,
                                  ),
                                  child: CText(
                                      "restore_purchase".i18n.toUpperCase(),
                                      style: tsButton.copiedWith(
                                        color: pink5,
                                      )),
                                ),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
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

  ///If the user is already so not ask for email
  ///f the user is not pro, ask for email
  void _onPromoCodeTap(BuildContext context, bool proUser) {
    if (!sessionModel.isAuthEnabled.value!) {
      context.pushRoute(ResellerCodeCheckoutLegacy(isPro: proUser));
      return;
    }
    if (proUser) {
      context.pushRoute(
        ResellerCodeCheckout(isPro: true, email: sessionModel.userEmail.value!),
      );
    } else {
      context
          .pushRoute(CreateAccountEmail(authFlow: AuthFlow.proCodeActivation));
    }
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
        onTap: () => _onPromoCodeTap(context, proUser),
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

  void restorePurchases(BuildContext context) {
    try {
      if (Platform.isIOS) {
        context.loaderOverlay.show();
        sl<AppPurchase>().restorePurchases(
          purchase: (purchase) {
            context.loaderOverlay.hide();
            if (purchase != null) {
              logger.e("no purchase found");
              CDialog.noPurchaseFound(context);
            } else {
              restorePurchasesVerification(
                  context,
                  PurchaseDetails(
                    productID: '1y',
                    transactionDate: '2021-09-01',
                    verificationData: PurchaseVerificationData(
                        localVerificationData: "12",
                        serverVerificationData: "dfd",
                        source: "source"),
                    purchaseID: '1',
                    status: PurchaseStatus.purchased,
                  ));
              logger.d("purchase found $purchase");
            }
          },
        );
      } else {
        sessionModel.restorePurchase();
      }
    } catch (e, stackTrace) {
      showError(context, error: e.localizedDescription, stackTrace: stackTrace);
    }
  }

  void restorePurchasesVerification(
      BuildContext context, PurchaseDetails purchaseDetails) {
    context.pushRoute(
        RestorePurchaseVerification(purchaseDetails: purchaseDetails));
  }
}
