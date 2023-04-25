import 'package:email_validator/email_validator.dart';
import 'package:lantern/plans/payment_provider.dart';
import 'package:lantern/plans/plans.dart';
import 'package:lantern/plans/price_summary.dart';
import 'package:lantern/plans/stripe_checkout.dart';
import 'package:lantern/common/common.dart';

final paymentProviders = [
  'stripe',
  'btc',
];

class Checkout extends StatefulWidget {
  final List<Map<String, dynamic>> plans;
  final String id;
  final bool isPro;

  Checkout({
    required this.plans,
    required this.id,
    required this.isPro,
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
                (6 <= value.characters.length && value.characters.length <= 13)
            ? null
            : 'Invalid or incomplete referral code'.i18n,
  );

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
                    child: Row(
                      children: [
                        const CAssetImage(path: ImagePaths.add),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8.0),
                          child: CText(
                            'Add Referral code'.i18n,
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
              // * Price summary, unused pro time disclaimer, Continue button
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PriceSummary(
                      plans: widget.plans,
                      id: widget.id,
                      isPro: widget.isPro,
                    ),
                    Button(
                      disabled: emailController.value.text.isEmpty ||
                          emailFieldKey.currentState?.validate() == false ||
                          refCodeFieldKey.currentState?.validate() == false,
                      text: 'Continue'.i18n,
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
  }

  Future<void> resolvePaymentRoute() async {
    if (selectedPaymentProvider == 'stripe') {
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
    } else {
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
        // TODO: get BTCPay URL with token from callback
        final btcPayURL = value as String;
        await context.pushRoute(
          FullScreenDialogPage(
            widget: Center(
              child: Stack(
                children: [
                  WebView(
                    initialUrl: btcPayURL,
                    // TODO: listen for WebView close
                  ),
                ],
              ),
            ),
          ),
        );
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
    }
    ;
  }
}
