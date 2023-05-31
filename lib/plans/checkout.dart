import 'package:lantern/common/common.dart';
import 'package:email_validator/email_validator.dart';
import 'package:lantern/plans/payment_provider.dart';
import 'package:lantern/plans/plan_details.dart';
import 'package:lantern/plans/price_summary.dart';
import 'package:lantern/plans/utils.dart';

enum Country { US, RU, CN }

class Checkout extends StatefulWidget {
  final List<Plan> plans;
  final String id;
  final bool isPro;
  final Plan selectedPlan;

  Checkout({
    required this.plans,
    required this.id,
    required this.isPro,
    required this.selectedPlan,
    Key? key,
  }) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout>
    with SingleTickerProviderStateMixin {
  bool showMoreOptions = false;
  final emailFieldKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    formKey: emailFieldKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );

  final refCodeFieldKey = GlobalKey<FormState>();
  late final refCodeController = CustomTextEditingController(
    formKey: refCodeFieldKey,
    validator: (value) =>
        // only allow letters and numbers as well as 6 <= length <= 13
        value != null &&
                RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value) &&
                (6 <= value.characters.length && value.characters.length <= 13)
            ? null
            : 'invalid_or_incomplete_referral_code'.i18n,
  );

  var isRefCodeFieldShowing = false;
  var selectedPaymentProvider = PaymentProviders.stripe;
  var loadingPercentage = 0;
  var submittedRefCode = false;
  late AnimationController animationController;
  late Animation pulseAnimation;
  var refCodeSuccessfullyApplied = false;

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
    emailController.dispose();
    refCodeController.dispose();
    animationController.dispose();
    super.dispose();
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
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: CAssetImage(
                    path: ImagePaths.down_arrow,
                  ),
                ),
              ])));

  void selectPaymentProvider(PaymentProviders provider) {
    setState(
      () => selectedPaymentProvider = provider,
    );
  }

  List<Widget> paymentOptions(Country countryCode) {
    var freekassa = PaymentProvider(
      logoPaths: [
        ImagePaths.mnp,
        ImagePaths.qiwi,
        ImagePaths.visa,
        ImagePaths.mastercard
      ],
      onChanged: () => selectPaymentProvider(PaymentProviders.freekassa),
      selectedPaymentProvider: selectedPaymentProvider,
      paymentType: PaymentProviders.freekassa,
    );

    var stripe = PaymentProvider(
      logoPaths: [ImagePaths.visa, ImagePaths.mastercard, ImagePaths.unionpay],
      onChanged: () => selectPaymentProvider(PaymentProviders.stripe),
      selectedPaymentProvider: selectedPaymentProvider,
      paymentType: PaymentProviders.stripe,
    );
    var btc = PaymentProvider(
      logoPaths: [ImagePaths.btc],
      onChanged: () => selectPaymentProvider(PaymentProviders.btc),
      selectedPaymentProvider: selectedPaymentProvider,
      paymentType: PaymentProviders.btc,
    );

    switch (countryCode) {
      case Country.CN:
        return [stripe, btc];
      case Country.US:
        return [stripe, btc, options(), if (showMoreOptions) freekassa];
      case Country.RU:
        return [freekassa, btc, if (showMoreOptions) stripe];
    }
    return [];
  }

  Future<void> resolvePaymentRoute() async {
    switch (selectedPaymentProvider) {
      case PaymentProviders.stripe:
        // * Stripe selected
        await context.pushRoute(
          StripeCheckout(
            plans: widget.plans,
            email: emailController.text,
            refCode: refCodeController.text,
            id: widget.id,
            isPro: widget.isPro,
          ),
        );
        break;
      case PaymentProviders.btc:
        // * BTC payment selected
        context.loaderOverlay.show();
        await sessionModel
            .submitBitcoinPayment(
              widget.id,
              emailController.text,
              refCodeController.text,
            )
            .timeout(
              defaultTimeoutDuration,
              onTimeout: () => onAPIcallTimeout(
                code: 'submitBitcoinTimeout',
                message: 'bitcoin_timeout'.i18n,
              ),
            )
            .then((value) async {
          context.loaderOverlay.hide();
          final btcPayURL = value as String;
          await sessionModel.openWebview(btcPayURL);
        }).onError((error, stackTrace) {
          context.loaderOverlay.hide();
          CDialog.showError(
            context,
            error: e,
            stackTrace: stackTrace,
            description: (error as PlatformException)
                .message
                .toString()
                .i18n // we are localizing this error Flutter-side,
            ,
          );
        });
        break;
      case PaymentProviders.freekassa:
        var strs = widget.id.split('-');
        if (strs.length < 2) break;
        var currency = strs[1];
        var currencyCost = widget.selectedPlan.price[currency];
        if (currencyCost == null) break;
        await sessionModel.submitFreekassa(
            emailController.text, widget.id, currencyCost.toString()!!);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return sessionModel.geoCountryCode(
        (BuildContext sessionContext, String countryCode, Widget? child) {
      return BaseScreen(
        resizeToAvoidBottomInset: false,
        title: 'lantern_pro_checkout'.i18n,
        body: Form(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              end: 16,
              top: 24,
              bottom: 32,
            ),
            child: ListView(
              children: [
                // * Step 2
                PlanStep(
                  stepNum: '2',
                  description: 'enter_email'.i18n,
                ),
                // * Email field
                Container(
                  padding: const EdgeInsetsDirectional.only(
                    top: 8,
                    bottom: 8,
                  ),
                  child: Form(
                    key: emailFieldKey,
                    child: CTextField(
                      controller: emailController,
                      autovalidateMode: AutovalidateMode.disabled,
                      label: 'email'.i18n,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const CAssetImage(path: ImagePaths.email),
                    ),
                  ),
                ),
                // * Referral Code field - initially hidden
                Visibility(
                  visible: isRefCodeFieldShowing,
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(
                      top: 8,
                      bottom: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Form(
                            key: refCodeFieldKey,
                            child: CTextField(
                              enabled: !refCodeSuccessfullyApplied,
                              controller: refCodeController,
                              autovalidateMode: AutovalidateMode.disabled,
                              textCapitalization: TextCapitalization.characters,
                              label: 'referral_code'.i18n,
                              keyboardType: TextInputType.text,
                              prefixIcon:
                                  const CAssetImage(path: ImagePaths.star),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              await sessionModel
                                  .applyRefCode(
                                    refCodeController.value.text,
                                  )
                                  .then(
                                    (value) => setState(() {
                                      submittedRefCode = true;
                                      refCodeSuccessfullyApplied = true;
                                    }),
                                  )
                                  .onError((error, stackTrace) {
                                CDialog.showError(
                                  context,
                                  error: e,
                                  stackTrace: stackTrace,
                                  description: (error as PlatformException)
                                      .message
                                      .toString()
                                      .i18n, // we are localizing this error Flutter-side
                                );
                                setState(() {
                                  refCodeSuccessfullyApplied = false;
                                });
                              });
                            },
                            child: Container(
                              padding: const EdgeInsetsDirectional.only(
                                start: 16.0,
                                end: 16.0,
                              ),
                              child: submittedRefCode &&
                                      refCodeFieldKey.currentState
                                              ?.validate() ==
                                          true &&
                                      refCodeSuccessfullyApplied
                                  ? Transform.scale(
                                      scale: pulseAnimation.value,
                                      child: const CAssetImage(
                                        path: ImagePaths.check_green,
                                      ),
                                    )
                                  : CText(
                                      'apply'.i18n.toUpperCase(),
                                      style: tsButtonPink,
                                    ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // * Add Referral code
                Visibility(
                  visible: !isRefCodeFieldShowing,
                  child: GestureDetector(
                    onTap: () async =>
                        setState(() => isRefCodeFieldShowing = true),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsetsDirectional.only(
                        top: 8,
                        bottom: 16,
                      ),
                      child: Row(
                        children: [
                          const CAssetImage(path: ImagePaths.add),
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 8.0),
                            child: CText(
                              'add_referral_code'.i18n,
                              style: tsBody1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // * Step 3
                PlanStep(
                  stepNum: '3',
                  description: 'choose_payment_method'.i18n,
                ),
                //* Payment options
                Container(
                  padding:
                      const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: paymentOptions(Country.values.firstWhere(
                        (e) => e.toString() == 'Country.' + countryCode)),
                  ),
                ),
                // * Price summary, unused pro time disclaimer, Continue button
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Button(
                        disabled: emailController.value.text.isEmpty ||
                            emailFieldKey.currentState?.validate() == false ||
                            refCodeFieldKey.currentState?.validate() == false,
                        text: 'continue'.i18n,
                        onPressed: () async {
                          await Future.wait(
                            [
                              sessionModel
                                  .checkEmailExists(emailController.value.text)
                                  .onError((error, stackTrace) {
                                CDialog.showError(
                                  context,
                                  error: e,
                                  stackTrace: stackTrace,
                                  description: error.toString(),
                                );
                              }),
                              resolvePaymentRoute(),
                            ],
                            eagerError: true,
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
