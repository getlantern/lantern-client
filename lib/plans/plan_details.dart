import 'package:lantern/common/common.dart';
import 'package:lantern/core/purchase/app_purchase.dart';
import 'package:lantern/plans/utils.dart';

class PlanCard extends StatefulWidget {
  final Plan plan;
  final bool isPro;

  const PlanCard({
    required this.plan,
    required this.isPro,
    Key? key,
  }) : super(key: key);

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  final appPurchase = sl<AppPurchase>();

  @override
  Widget build(BuildContext context) {
    final planName = widget.plan.id.split('-')[0];
    final formattedPricePerYear = widget.plan.totalCostBilledOneTime;
    final totalCost = widget.plan.totalCost;
    final formattedPricePerMonth = widget.plan.oneMonthCost;
    final isBestValue = widget.plan.bestValue;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 14.0),
      child: CInkWell(
        onTap: () => onPlanTap(context),
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
                  top: 16.0,
                  bottom: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // * Plan name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CText(
                          getPlanDisplayName(planName),
                          style: tsSubtitle2.copiedWith(
                            color: pink3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsetsDirectional.only(top: 8),
                          child: const Icon(Icons.keyboard_arrow_right),
                        ),
                      ],
                    ),
                    // * Price per month
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (Platform.isIOS)
                          CText(getPrice(totalCost), style: tsHeading1)
                        else
                          CText(formattedPricePerMonth, style: tsHeading1),
                        if (!Platform.isIOS) ...{
                          CText(' / ', style: tsBody2),
                          CText('month'.i18n, style: tsBody2),
                        }
                      ],
                    ),
                    if (Platform.isIOS)
                      CText('non_renewing_subscription'.i18n,
                          style: tsBody2.copiedWith(color: grey5))
                    else
                      CText(
                        formattedPricePerYear,
                        style: tsBody2.copiedWith(color: grey5),
                      ),
                  ],
                ),
              ),
            ),
            if (isBestValue)
              Transform.translate(
                offset: const Offset(0.0, 10.0),
                child: Card(
                  key: AppKeys.mostPopular,
                  color: yellow4,
                  shadowColor: grey2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: isBestValue ? 3 : 1,
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12.0,
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

  String getPlanDisplayName(String plan) {
    if (Platform.isIOS) {
      if (plan == '1y') {
        return 'lantern_pro_one_year'.i18n;
      } else if (plan == '1m') {
        return 'lantern_pro_one_month'.i18n;
      } else {
        return 'lantern_pro_two_year'.i18n;
      }
    } else {
      if (plan == '1y') {
        return 'one_year_plan'.i18n;
      } else if (plan == '1m') {
        return 'one_month_plan'.i18n;
      } else {
        return 'two_year_plan'.i18n;
      }
    }
  }

  String getPrice(String totalCost) {
    final appStorePrice = appPurchase.getPriceFromPlanId(widget.plan.id);
    return appStorePrice == '' ? totalCost : appStorePrice;
  }

// paymentProvidersFromMethods returns a list of payment providers that correspond with payment methods available to a user
  List<PaymentProviders> paymentProvidersFromMethods(
      Iterable<PathAndValue<PaymentMethod>> paymentMethods) {
    var providers = <PaymentProviders>[];
    for (final paymentMethod in paymentMethods) {
      for (final provider in paymentMethod.value.providers) {
        providers.add(provider);
      }
    }
    return providers;
  }

  Future<void> onPlanTap(BuildContext context) async {
    switch (Platform.operatingSystem) {
      case 'ios':
        if (widget.isPro) {
          _proceedToCheckoutIOS(context);
          return;
        }

        /// There is edge case where user is signup with email and password but not pro
        /// this happens when does restore purchase on other device so older device
        /// does not have pro status but have email and password
        if (sessionModel.hasUserSignedInNotifier.value ?? false) {
          _proceedToCheckoutIOS(context);
          return;
        }
        _storeFlow();
        break;
      default:
        //Support for legacy purchase flow
        if (!sessionModel.isAuthEnabled.value!) {
          _processLegacyCheckOut(context);
          return;
        }
        if (widget.isPro) {
          _processCheckOut(context);
          return;
        } else {
          if (await isPlayStoreEnabled()) {
            _storeFlow();
            return;
          }
          signUpFlow();
        }
        break;
    }
  }

  Future<void> _processLegacyCheckOut(BuildContext context) async {
    if (await isPlayStoreEnabled()) {
      await context.pushRoute(
        StoreCheckout(
          plan: widget.plan,
        ),
      );
      return;
    }
    await context.pushRoute(
      CheckoutLegacy(
        plan: widget.plan,
        isPro: widget.isPro,
      ),
    );
  }

  Future<void> _processCheckOut(BuildContext context) async {
    if (await isPlayStoreEnabled()) {
      final email = sessionModel.userEmail.value;
      _proceedToGooglePlayPurchase(email!!);
      return;
    }
    final email = sessionModel.userEmail.value;
    // * Proceed to our own Checkout
    await context.pushRoute(
      Checkout(
        plan: widget.plan,
        isPro: widget.isPro,
        email: email,
      ),
    );
  }

  void resolveRoute() {
    if (widget.isPro) {
      showSuccessDialog(context, widget.isPro);
    } else {
      /// There is edge case where user is signup with email and password but not pro
      /// this happens when does restore purchase on other device so older device
      /// does not have pro status but have email and password
      if (sessionModel.hasUserSignedInNotifier.value ?? false) {
        showSuccessDialog(context, widget.isPro);
        return;
      }
      signUpFlow();
    }
  }

  void signUpFlow() {
    // If user is new we need to send plans id to create account flow
    context.pushRoute(CreateAccountEmail(
        authFlow: AuthFlow.createAccount, plan: widget.plan));
  }

  void _proceedToCheckoutIOS(BuildContext context) {
    final appPurchase = sl<AppPurchase>();
    try {
      context.loaderOverlay.show();
      appPurchase.startPurchase(
        email: sessionModel.userEmail.value ?? '',
        planId: widget.plan.id,
        onSuccess: () {
          context.loaderOverlay.hide();
          resolveRoute();
        },
        onFailure: (error) {
          context.loaderOverlay.hide();
          CDialog.showError(
            context,
            error: error,
            description: error.toString(),
          );
        },
      );
    } catch (e) {
      context.loaderOverlay.hide();
      CDialog.showError(
        context,
        error: e,
        description: e.toString(),
      );
    }
  }

  Future<void> _proceedToGooglePlayPurchase(String email) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.submitPlayPayment(widget.plan.id, email);
      context.loaderOverlay.hide();
      resolveRoute();
    } catch (e) {
      context.loaderOverlay.hide();
      showError(context, error: e);
    }
  }

  void _storeFlow() {
    context.pushRoute(StoreCheckout(
      plan: widget.plan,
    ));
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
          ),
          decoration: BoxDecoration(
            color: black,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            margin: const EdgeInsetsDirectional.only(bottom: 4.0),
            child: CText(
              'step_$stepNum'.i18n,
              style: tsBody1.copiedWith(color: white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsetsDirectional.only(start: 8.0),
          margin: const EdgeInsetsDirectional.only(bottom: 4.0),
          child: CText(description, style: tsBody1),
        )
      ],
    );
  }
}
