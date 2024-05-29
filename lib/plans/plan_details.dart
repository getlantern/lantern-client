import 'package:lantern/common/common.dart';
import 'package:lantern/core/purchase/app_purchase.dart';
import 'package:lantern/plans/utils.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final bool isPro;

  const PlanCard({
    required this.plan,
    required this.isPro,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final planName = plan.id.split('-')[0];
    final formattedPricePerYear = plan.totalCostBilledOneTime;
    final formattedPricePerMonth = plan.oneMonthCost;
    final isBestValue = plan.bestValue;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16.0),
      child: CInkWell(
        onTap: () => onPlanTap(context, plan),
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

  Future<void> onPlanTap(BuildContext context, Plan plan) async {
    if (Platform.isAndroid) {
      _proceedToAndroidCheckout(context, plan.id.split('-')[0]);
    } else {
      /// If user is already pro user is trying to renew plans
      /// if the user is not pro user then user is trying to purchase
      if (isPro && sessionModel.hasUserSignedInNotifier.value == true) {
        _proceedToCheckoutIOS(context);
      } else {
        context.pushRoute(CreateAccountEmail(plan: plan));
      }
    }
  }

  Future<void> _proceedToAndroidCheckout(
      BuildContext context, String planName) async {
    final isPlayVersion = sessionModel.isPlayVersion.value ?? false;
    final inRussia = sessionModel.country.value == 'RU';
    //If user is downloaded from Play store and !inRussia then
    //Go with In App purchase

    if (isPlayVersion && !inRussia) {
      context.pushRoute(PlayCheckout(plan: plan, isPro: isPro));
      // await sessionModel
      //     .submitPlayPayment(,planName)
      //     .onError((error, stackTrace) {
      //   // on failure
      //   CDialog.showError(
      //     context,
      //     error: e,
      //     stackTrace: stackTrace,
      //     description: (error as PlatformException).message ?? error.toString(),
      //   );
      // });
    } else {
      _proceedToCustomCheckout(context);
    }
  }

  Future<void> _proceedToCustomCheckout(BuildContext context) async {
  void onPlanTap(BuildContext context) {
    switch (Platform.operatingSystem) {
      case 'ios':
        throw Exception("Not support at the moment");
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
          plan: plan,
          isPro: isPro,
        ),
      );
      return;
    } else if (isDesktop()) {
      final paymentMethods = await sessionModel.paymentMethodsv4();
      final providers = paymentProvidersFromMethods(paymentMethods);
      // if only one payment provider is returned, bypass the last checkout screen
      // Note: as of now, we only do this for Stripe since it is the only payment provider that collects email
      if (providers.length == 1 && providers[0].name.toPaymentEnum() == Providers.stripe) {
        final providerName = providers[0].name.toPaymentEnum();
        final redirectUrl = await sessionModel.paymentRedirectForDesktop(
          context,
          plan.id,
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
        plan: plan,
        isPro: isPro,
      ),
    );
  }

  //Todo get the latest email from the session model
  void _proceedToCheckoutIOS(BuildContext context) {
    final appPurchase = sl<AppPurchase>();
    try {
      context.loaderOverlay.show();
      appPurchase.startPurchase(
        email: sessionModel.userEmail.value ?? "",
        planId: plan.id,
        onSuccess: () {
          context.loaderOverlay.hide();
          showSuccessDialog(context, isPro);
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
