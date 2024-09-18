import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/plans/payment_provider.dart';
import 'package:lantern/plans/utils.dart';
import 'package:retry/retry.dart';

@RoutePage(name: 'Checkout')
class Checkout extends StatefulWidget {
  final Plan plan;
  final bool isPro;
  final AuthFlow? authFlow;
  final String? verificationPin;
  final String? email;

  const Checkout({
    required this.plan,
    required this.isPro,
    this.authFlow,
    this.email,
    this.verificationPin,
    Key? key,
  }) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout>
    with SingleTickerProviderStateMixin {
  bool showMoreOptions = false;
  bool showContinueButton = false;

  final refCodeFieldKey = GlobalKey<FormState>();
  late final refCodeController = CustomTextEditingController(
    formKey: refCodeFieldKey,
    validator: (value) =>
        // only allow letters and numbers as well as 6 <= length <= 13
        value == null ||
                value.characters.isEmpty ||
                RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value) &&
                    (6 <= value.characters.length &&
                        value.characters.length <= 13)
            ? null
            : 'invalid_or_incomplete_referral_code'.i18n,
  );

  var isRefCodeFieldShowing = false;
  Providers? selectedPaymentProvider;
  var loadingPercentage = 0;
  late AnimationController animationController;
  late Animation pulseAnimation;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: longAnimationDuration);
    animationController.repeat(reverse: true);
    pulseAnimation =
        Tween<double>(begin: 0.5, end: 1.5).animate(animationController);

    if (animationController.isCompleted) animationController.stop();

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        resizeToAvoidBottomInset: false,
        title: 'lantern_pro_checkout'.i18n,
        padHorizontal: true,
        padVertical: true,
        body: sessionModel.paymentMethods(
          builder: (
            context,
            Iterable<PathAndValue<PaymentMethod>> paymentMethods,
            Widget? child,
          ) {
            if (paymentMethods.isEmpty) {
              return const SizedBox();
            }

            defaultProviderIfNecessary(paymentMethods.toList());
            return Column(
              children: [
                CText('choose_payment_method'.i18n, style: tsHeading1),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: paymentOptions(paymentMethods)),
                ),
                if (isRefCodeFieldShowing)
                  Form(
                    key: refCodeFieldKey,
                    child: CTextField(
                      controller: refCodeController,
                      autovalidateMode: AutovalidateMode.disabled,
                      onChanged: (text) {
                        setState(() {
                          showContinueButton = enableContinueButton();
                        });
                      },
                      textCapitalization: TextCapitalization.characters,
                      label: 'referral_code'.i18n,
                      keyboardType: TextInputType.text,
                      prefixIcon: const CAssetImage(path: ImagePaths.star),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isRefCodeFieldShowing = true;
                      });
                    },
                    child: Row(
                      children: [
                        const CAssetImage(path: ImagePaths.add),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 8.0,
                          ),
                          child: CText(
                            'add_referral_code'.i18n,
                            style: tsBody1,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Tooltip(
                  message: AppKeys.continueCheckout,
                  child: SizedBox(
                    width: double.infinity,
                    child: Button(
                      text: 'continue'.i18n,
                      disabled: !enableContinueButton(),
                      onPressed: onContinueTapped,
                    ),
                  ),
                ),
              ],
            );
          },
        ));
  }

  Widget options() => CInkWell(
        onTap: () {
          setState(() {
            showMoreOptions = !showMoreOptions;
          });
        },
        child: Container(
          padding: const EdgeInsetsDirectional.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CText(
                showMoreOptions ? 'fewer_options'.i18n : 'more_options'.i18n,
                style: tsBody1,
              ),
              const Padding(
                padding: EdgeInsetsDirectional.only(start: 8),
                child: CAssetImage(
                  path: ImagePaths.down_arrow,
                ),
              ),
            ],
          ),
        ),
      );

  List<Widget> paymentOptions(
    Iterable<PathAndValue<PaymentMethod>> paymentMethods,
  ) {
    var widgets = <Widget>[];
    for (final pathAndValue in paymentMethods) {
      final paymentMethod = pathAndValue.value;
      if (widgets.length == 2) {
        if (paymentMethods.length != 2) widgets.add(options());
        if (!showMoreOptions) break;
      }
      widgets.addAll(paymentProviders(paymentMethod));
    }
    return widgets;
  }

  List<PaymentProvider> paymentProviders(PaymentMethod paymentMethods) {
    var providers = <PaymentProvider>[];
    for (final provider in paymentMethods.providers) {
      providers.add(
        PaymentProvider(
          logoPaths: provider.logoUrls,
          onChanged: () => selectPaymentProvider(provider.name.toPaymentEnum()),
          selectedPaymentProvider: selectedPaymentProvider!,
          paymentType: provider.name.toPaymentEnum(),
          useNetwork: true,
        ),
      );
    }
    return providers;
  }

  bool enableContinueButton() {
    if (!isRefCodeFieldShowing || refCodeController.text.isEmpty) {
      return true;
    }
    return refCodeFieldKey.currentState!.validate();
  }

  //Class methods
  void selectPaymentProvider(Providers provider) {
    setState(
      () => selectedPaymentProvider = provider,
    );
  }

  void checkProUser() async {
    final res = sessionModel.proUserNotifier.value ?? false;
    if (!widget.isPro && res) {
      // show success dialog if user becomes Pro during browser session
      showSuccessDialog(context, widget.isPro);
    }
  }

  Future<void> resolvePaymentMethod() async {
    final provider = selectedPaymentProvider!;
    if (isDesktop() && provider != Providers.test) {
      _proceedWithPaymentRedirect(provider);
      return;
    }
    switch (provider) {
      case Providers.stripe:
        _proceedWithStripe();
        break;
      case Providers.btcpay:
        _proceedWithBTCPay();
        break;
      case Providers.freekassa:
        _proceedWithFreekassa();
        break;
      case Providers.fropay:
        _proceedWithFroPay();
      case Providers.shepherd:
        _proceedWithShepherd();
        return;
      case Providers.paymentwall:
        _proceedWithPaymentWall();
        return;
      case Providers.test:
        _proceedTestRequest();
        return;
    }
  }

  Future<void> _proceedWithStripe() async {
    await context.pushRoute(
      StripeCheckout(
        email: widget.email!,
        refCode: refCodeController.text,
        plan: widget.plan,
        isPro: widget.isPro,
      ),
    );
  }

  void _proceedWithBTCPay() async {
    try {
      context.loaderOverlay.show();
      final value = await sessionModel.generatePaymentRedirectUrl(
          planID: widget.plan.id,
          email: widget.email!,
          paymentProvider: Providers.btcpay);

      context.loaderOverlay.hide();
      final btcPayURL = value;
      await AppBrowser.openWebview(btcPayURL);
    } catch (error, stackTrace) {
      context.loaderOverlay.hide();
      showError(context, error: error, stackTrace: stackTrace);
    }
  }

  void _proceedWithFroPay() async {
    try {
      context.loaderOverlay.show();

      final value = await sessionModel.generatePaymentRedirectUrl(
          planID: widget.plan.id,
          email: widget.email!,
          paymentProvider: Providers.fropay);

      context.loaderOverlay.hide();
      final froPayURL = value;
      await AppBrowser.openWebview(froPayURL);
    } catch (error, stackTrace) {
      context.loaderOverlay.hide();
      showError(context, error: error, stackTrace: stackTrace);
    }
  }

  void _proceedTestRequest() async {
    try {
      context.loaderOverlay.show();
      final value = await sessionModel.testProviderRequest(
          widget.email!, Providers.test.name, widget.plan.id);
      context.loaderOverlay.hide();
      if (widget.isPro) {
        showSuccessDialog(context, widget.isPro);
      } else {
        resolveRoute();
      }
    } catch (error, stackTrace) {
      context.loaderOverlay.hide();
      showError(context, error: error, stackTrace: stackTrace);
    }
  }

  void _proceedWithShepherd() async {
    try {
      context.loaderOverlay.show();

      final value = await sessionModel.generatePaymentRedirectUrl(
          planID: widget.plan.id,
          email: widget.email!,
          paymentProvider: Providers.shepherd);

      context.loaderOverlay.hide();
      final shepherdURL = value;
      await AppBrowser.openWebview(shepherdURL);
    } catch (error, stackTrace) {
      context.loaderOverlay.hide();
      showError(context, error: error, stackTrace: stackTrace);
    }
  }


  // This methods is responsible for polling for user data
  // so if user has done payment or renew plans and show
  void hasPlansUpdateOrBuy() {
    appLogger.i("calling hasPlansUpdateOrBuy to update plans or buy");
    try {
      retry(
        () async {
          /// Polling for userData that user has updates plans or buy
          final plansUpdated = await sessionModel.hasUpdatePlansOrBuy();
          if (plansUpdated) {
            if (mounted) {
              showSuccessDialog(context, widget.isPro);
            }
          }
        },
        delayFactor: const Duration(seconds: 2),
        retryIf: (e) => e is NoPlansUpdate,
      );
    } catch (e) {
      appLogger.e('Error while polling for plans update or buy', error: e);
    }
  }

  void _proceedWithPaymentRedirect(Providers provider) async {
    try {
      context.loaderOverlay.show();
      final redirectUrl = await sessionModel.paymentRedirectForDesktop(
        context,
        widget.plan.id,
        widget.email!,
        provider,
      );
      context.loaderOverlay.hide();
      openDesktopPaymentWebview(
          context: context,
          provider: provider,
          redirectUrl: redirectUrl,
          onClose: checkProUser);
      // as soon user click we should start polling userData
      Future.delayed(const Duration(seconds: 2), hasPlansUpdateOrBuy);
    } catch (error, stackTrace) {
      context.loaderOverlay.hide();
      showError(context, error: error, stackTrace: stackTrace);
    }
  }

  void _proceedWithPaymentWall() async {
    try {
      context.loaderOverlay.show();
      final value = await sessionModel.generatePaymentRedirectUrl(
          planID: widget.plan.id,
          email: widget.email!,
          paymentProvider: Providers.paymentwall);

      context.loaderOverlay.hide();
      final btcPayURL = value;
      await AppBrowser.openWebview(btcPayURL);
    } catch (error, stackTrace) {
      context.loaderOverlay.hide();
      showError(context, error: error, stackTrace: stackTrace);
    }
  }

  // It starts native activity to proceed with Freekassa
  Future<void> _proceedWithFreekassa() async {
    try {
      var strs = widget.plan.id.split('-');
      if (strs.length < 2) return;
      var currency = strs[1];
      var currencyCost = widget.plan.price[currency];
      if (currencyCost == null) return;
      await sessionModel.submitFreekassa(
        widget.email!,
        widget.plan.id,
        currencyCost.toString(),
      );
    } catch (e) {
      showError(context, error: e);
    }
  }

  void defaultProviderIfNecessary(List<PathAndValue<PaymentMethod>> list) {
    if (selectedPaymentProvider != null) {
      return;
    }
    if (list.isEmpty) {
      return;
    }
    final paymentMethod = list[0].value;
    if (paymentMethod.providers.isEmpty) {
      return;
    }
    //By default zero value is default
    //If needed to change default value changing to from server
    selectedPaymentProvider = paymentMethod.providers[0].name.toPaymentEnum();
  }

  Future<void> onContinueTapped() async {
    var refCode = refCodeController.value;
    try {
      if (refCode.text.isNotEmpty) {
        await sessionModel.applyRefCode(refCode.text);
      }
      resolvePaymentMethod();
    } catch (e) {
      if (refCode.text.isNotEmpty) {
        refCodeController.error = 'invalid_or_incomplete_referral_code'.i18n;
        return;
      }
      showError(context, error: e.localizedDescription);
    }
  }

  void resolveRoute() {
    assert(widget.authFlow != null, 'authFlow is null');
    switch (widget.authFlow!) {
      case AuthFlow.createAccount:
      /// There is edge case where user is signup with email and password but not pro
      /// this happens when does restore purchase on other device so older device
      /// does not have pro status but have email and password
        if (sessionModel.hasUserSignedInNotifier.value ?? false) {
          showSuccessDialog(context, widget.isPro);
          return;
        }

        context.pushRoute(CreateAccountPassword(
          email: widget.email.validateEmail,
          code: widget.verificationPin!,
        ));
        break;
      case AuthFlow.reset:
        // TODO: Handle this case.
        break;
      case AuthFlow.signIn:
        // TODO: Handle this case.
        break;

      case AuthFlow.verifyEmail:
      // TODO: Handle this case.
      case AuthFlow.proCodeActivation:
      // TODO: Handle this case.
      case AuthFlow.changeEmail:
      // TODO: Handle this case.
      case AuthFlow.updateAccount:
      // TODO: Handle this case.
      case AuthFlow.restoreAccount:
        // TODO: Handle this case.
    }
  }
}
