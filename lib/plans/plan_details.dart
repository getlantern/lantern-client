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
    final totalCost = widget.plan.totalCost;
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
                              ? Platform.isIOS
                                  ? 'lantern_pro_one_year'.i18n
                                  : 'one_year_plan'.i18n
                              : Platform.isIOS
                                  ? 'lantern_pro_two_year'.i18n
                                  : 'two_year_plan'.i18n,
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
                          CText(totalCost, style: tsHeading1)
                        else
                          CText(formattedPricePerMonth, style: tsHeading1),
                       if(!Platform.isIOS)...{
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
        resolveRouteIOS();
        break;
      default:
        // proceed to the default checkout page on Android and desktop
        _checkOut(context);
        break;
    }
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

  Future<void> _checkOut(BuildContext context) async {
    final isPlayVersion = sessionModel.isPlayVersion.value ?? false;
    final inRussia = sessionModel.country.value == 'RU';
    // * Play version (Android only)
    if (isPlayVersion && !inRussia) {
      await context.pushRoute(
        PlayCheckout(
          plan: widget.plan,
          isPro: widget.isPro,
        ),
      );
      return;
    } else if (isDesktop()) {
      final paymentMethods = await sessionModel.paymentMethodsv4();
      final providers = paymentProvidersFromMethods(paymentMethods);
      // if only one payment provider is returned, bypass the last checkout screen
      // Note: as of now, we only do this for Stripe since it is the only payment provider that collects email
      if (providers.length == 1 &&
          providers[0].name.toPaymentEnum() == Providers.stripe) {
        final providerName = providers[0].name.toPaymentEnum();
        final redirectUrl = await sessionModel.paymentRedirectForDesktop(
          context,
          widget.plan.id,
          "",
          providerName,
        );
        await openDesktopWebview(
            context: context, provider: providerName, redirectUrl: redirectUrl);
        return;
      }
    }

    // * Proceed to our own Checkout
    await context.pushRoute(
      Checkout(
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
