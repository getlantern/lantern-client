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
  @override
  Widget build(BuildContext context) {
    final planName = widget.plan.id.split('-')[0];
    final formattedPricePerYear = widget.plan.totalCostBilledOneTime;
    final formattedPricePerMonth = widget.plan.oneMonthCost;
    final isBestValue = widget.plan.bestValue;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16.0),
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
                          planName == '1y'
                              ? 'one_year_plan'.i18n
                              : (planName == '1m'
                                  ? 'one_month_plan'.i18n
                                  : 'two_year_plan'.i18n),
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

  void onPlanTap(BuildContext context) {
    switch (Platform.operatingSystem) {
      case 'ios':
        if (!sessionModel.isAuthEnabled.value!) {
          ///Legacy checkout flow
          context.pushRoute(
            PlayCheckout(
              plan: widget.plan,
              isPro: widget.isPro,
            ),
          );
          return;
        }
        resolveRouteIOS();
        break;
      default:
        if (!sessionModel.isAuthEnabled.value!) {
          _processLegacyCheckOut(context);
          return;
        }
        if (widget.isPro) {
          _processCheckOut(context);
        } else {
          signUpFlow();
        }
        break;
    }
  }

  // paymentProvidersFromMethods returns a list of payment providers that correspond with payment methods available to a user
  List<PaymentProviders> paymentProvidersFromMethods(
      Iterable<PaymentMethod> paymentMethods) {
    var providers = <PaymentProviders>[];
    paymentMethods.forEach((value) => providers.addAll(value.providers));
    return providers;
  }

  void signUpFlow() {
    // If user is new we need to send plans id to create account flow
    context.pushRoute(CreateAccountEmail(
        authFlow: AuthFlow.createAccount, plan: widget.plan));
  }

  Future<void> _processCheckOut(BuildContext context) async {
    if (await AppMethods.isPlayStoreEnable()) {
      await context.pushRoute(
        PlayCheckout(
          plan: widget.plan,
          isPro: widget.isPro,
        ),
      );
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

  Future<void> _processLegacyCheckOut(BuildContext context) async {
    if (await AppMethods.isPlayStoreEnable()) {
      await context.pushRoute(
        PlayCheckout(
          plan: widget.plan,
          isPro: widget.isPro,
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

  void resolveRouteIOS() {
    if (widget.isPro) {
      //user is signed in
      _proceedToCheckoutIOS(context);
    } else {
      signUpFlow();
    }
  }

  void _proceedToCheckoutIOS(BuildContext context) {
    final appPurchase = sl<AppPurchase>();
    try {
      context.loaderOverlay.show();
      appPurchase.startPurchase(
        email: sessionModel.userEmail.value ?? "",
        planId: widget.plan.id,
        onSuccess: () {
          context.loaderOverlay.hide();
          showSuccessDialog(context, widget.isPro);
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

  // Make sure this google play flow is only for play version
  // it will take care of purchase flow and also calling /purchase api on native end
  Future<void> _processGooglePlayPayment() async {
    try {
      context.loaderOverlay.show();
      await sessionModel.submitPlayPayment(
          widget.plan!.id, sessionModel.userEmail.value!);
      context.loaderOverlay.hide();
      sessionModel.updateUserDetails();
      Future.delayed(const Duration(milliseconds: 400), () {
        context.loaderOverlay.hide();
        showSuccessDialog(context, widget.isPro);
      });
    } catch (e) {
      mainLogger.e("Error while purchase flow", error: e);
      context.loaderOverlay.hide();
      CDialog.showError(
        context,
        error: e,
        description: e.localizedDescription,
      );
    }
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
