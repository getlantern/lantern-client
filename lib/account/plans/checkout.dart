import 'package:email_validator/email_validator.dart';
import 'package:lantern/account/plans/payment_provider_button.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/account/plans/price_summary.dart';
import 'package:lantern/common/common.dart';

import 'purchase_constants.dart';
import 'purchase_utils.dart';

class Checkout extends StatefulWidget {
  final List<Map<String, Object>> plans;
  final String id;
  final bool isPro;
  final bool isPlatinum;

  Checkout({
    required this.plans,
    required this.id,
    required this.isPro,
    required this.isPlatinum,
    Key? key,
  }) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout>
    with SingleTickerProviderStateMixin {
  final emailFieldKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    formKey: emailFieldKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'Please enter a valid email address'.i18n,
  );

  final refCodeFieldKey = GlobalKey<FormState>();
  late final refCodeController = CustomTextEditingController(
    formKey: refCodeFieldKey,
    validator: (value) =>
        // only allow letters and numbers as well as 6 <= length <= 13
        value != null &&
                RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value) &&
                (6 <= value.characters.length &&
                    value.characters.length <= 13) &&
                refCodeSuccessfullyApplied
            ? null
            : 'Your referral code is invalid'.i18n,
  );

  final referralCode = '';
  var isRefCodeFieldShowing = false;
  var selectedPaymentProvider = paymentProviders[0];
  var loadingPercentage = 0;
  var submittedRefCode = false;
  late AnimationController animationController;
  late Animation pulseAnimation;
  var refCodeSuccessfullyApplied = false;

  @override
  void initState() {
    WebView.platform = AndroidWebView();

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

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      resizeToAvoidBottomInset: false,
      title: 'Lantern ${widget.isPro == true ? 'Pro' : ''} Checkout'.i18n,
      body: Form(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 24,
            bottom: 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // * Step 2
              PlanStep(
                stepNum: '2',
                description: 'Enter email'.i18n,
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
                    label: 'Email'.i18n,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const CAssetImage(path: ImagePaths.email),
                  ),
                ),
              ),
              // * Referral Code field
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
                            enabled: !submittedRefCode,
                            controller: refCodeController,
                            autovalidateMode: AutovalidateMode.disabled,
                            label: 'Referral code'.i18n,
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
                                  emailController.text,
                                  referralCode,
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
                                    refCodeFieldKey.currentState?.validate() ==
                                        true &&
                                    refCodeSuccessfullyApplied
                                ? Transform.scale(
                                    scale: pulseAnimation.value,
                                    child: const CAssetImage(
                                      path: ImagePaths.check_green,
                                    ),
                                  )
                                : CText(
                                    'Apply'.i18n.toUpperCase(),
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
                    child: CText(
                      '+ Add Referral code ',
                      style: tsBody1,
                    ),
                  ),
                ),
              ),
              // * Step 3
              PlanStep(
                stepNum: '3',
                description: 'Choose Payment Method'.i18n,
              ),
              //* Payment options
              Container(
                padding: const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // * Stripe
                    PaymentProviderButton(
                      logoPaths: [ImagePaths.visa, ImagePaths.mastercard],
                      onChanged: () => setState(
                        () => selectedPaymentProvider = 'stripe',
                      ),
                      selectedPaymentProvider: selectedPaymentProvider,
                      paymentType: 'stripe',
                    ),
                    // * BTC
                    PaymentProviderButton(
                      logoPaths: [ImagePaths.btc],
                      onChanged: () => setState(
                        () => selectedPaymentProvider = 'btc',
                      ),
                      selectedPaymentProvider: selectedPaymentProvider,
                      paymentType: 'btc',
                    )
                  ],
                ),
              ),
              //  TODO: Helper widget - remove
              sessionModel.developmentMode(
                (context, isDeveloperMode, child) => isDeveloperMode
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            emailController.text = 'test@email.com';
                          },
                          child: Container(
                            padding: const EdgeInsetsDirectional.all(24.0),
                            child: CText(
                              'DEV PURPOSES - TAP TO PREFILL',
                              style: tsButtonBlue,
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PriceSummary(
                    plans: widget.plans,
                    id: widget.id,
                    isPlatinum: widget.isPlatinum,
                    isPro: widget.isPro,
                  ),
                  // * Continue to Payment
                  Button(
                    disabled: emailController.value.text.isEmpty ||
                        emailFieldKey.currentState?.validate() == false,
                    text: 'Continue'.i18n,
                    onPressed: () async {
                      if (selectedPaymentProvider == 'stripe') {
                        await context.pushRoute(
                          StripeCheckout(
                            plans: widget.plans,
                            email: emailController.text,
                            refCode: refCodeController.text,
                            id: widget.id,
                            isPlatinum: widget.isPlatinum,
                            isPro: widget.isPro,
                          ),
                        );
                      } else {
                        context.loaderOverlay.show();
                        await sessionModel
                            .submitBitcoin(
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
                          final btcPayURL = value
                              as String; // TODO: presumably we get the BTCPay URL with token from callback
                          await context.pushRoute(
                            FullScreenDialogPage(
                              widget: Center(
                                child: Stack(
                                  children: [
                                    WebView(
                                      initialUrl: btcPayURL,
                                      // TODO: we don't need to keep this loadingPercentage, it was boilerplate code
                                      onPageStarted: (url) {
                                        setState(() {
                                          loadingPercentage = 0;
                                        });
                                      },
                                      onProgress: (progress) {
                                        setState(() {
                                          loadingPercentage = progress;
                                        });
                                      },
                                      onPageFinished: (url) {
                                        setState(() {
                                          loadingPercentage = 100;
                                        });
                                      },
                                      // TODO: listen for WebView close and handle success
                                    ),
                                    if (loadingPercentage < 100)
                                      LinearProgressIndicator(
                                        value: loadingPercentage / 100.0,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).onError((error, stackTrace) {
                          context.loaderOverlay.hide();
                          CDialog.showError(context,
                              error: e,
                              stackTrace: stackTrace,
                              description: (error as PlatformException)
                                  .message
                                  .toString()
                                  .i18n // we are localizing this error Flutter-side,
                              );
                        });
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
