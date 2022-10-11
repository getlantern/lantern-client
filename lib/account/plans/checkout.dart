import 'package:email_validator/email_validator.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/account/plans/price_summary.dart';
import 'package:lantern/common/common.dart';

import 'payment_webview.dart';
import 'payment_provider_button.dart';
import 'plan_utils.dart';
import 'purchase_constants.dart';

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
  var refCodeSuccessfullyApplied = false;

  @override
  void initState() {
    WebView.platform = AndroidWebView();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    refCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      resizeToAvoidBottomInset: false,
      title: 'Lantern ${widget.isPro == true ? 'Pro' : ''} Checkout'.i18n,
      body: Container(
        padding: const EdgeInsetsDirectional.only(
          start: 8.0,
          end: 8.0,
          top: 24.0,
          bottom: 32.0,
        ),
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            ListView(
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
                    child: sessionModel.emailAddress(
                      (context, email, child) => CTextField(
                        enabled: email.isEmpty,
                        initialValue: email,
                        controller: emailController,
                        autovalidateMode: AutovalidateMode.disabled,
                        label: 'Email'.i18n,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const CAssetImage(path: ImagePaths.email),
                      ),
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
                              maxLength: 13,
                              enabled: !refCodeSuccessfullyApplied,
                              controller: refCodeController,
                              autovalidateMode: AutovalidateMode.disabled,
                              textCapitalization: TextCapitalization.characters,
                              label: 'Referral code'.i18n,
                              keyboardType: TextInputType.text,
                              prefixIcon:
                                  const CAssetImage(path: ImagePaths.star),
                              removeCounter: true,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: submittedRefCode &&
                                  refCodeFieldKey.currentState?.validate() ==
                                      true &&
                                  refCodeSuccessfullyApplied
                              ? const CAssetImage(
                                  path: ImagePaths.check_green,
                                )
                              : CInkWell(
                                  onTap: () async {
                                    await sessionModel
                                        .applyRefCode(
                                          refCodeController.value.text,
                                          emailController.value.text,
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
                                        description: (error
                                                as PlatformException)
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
                                    padding:
                                        const EdgeInsetsDirectional.all(16.0),
                                    child: CText(
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
                            padding:
                                const EdgeInsetsDirectional.only(start: 8.0),
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
                // * Payment options
                Container(
                  padding:
                      const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // * Alipay
                      PaymentProviderButton(
                        logoPaths: [ImagePaths.alipay],
                        onChanged: () => setState(
                          () => selectedPaymentProvider = 'alipay',
                        ),
                        selectedPaymentProvider: selectedPaymentProvider,
                        paymentType: 'alipay',
                      ),
                      // * BTC
                      PaymentProviderButton(
                        logoPaths: [ImagePaths.btc],
                        onChanged: () => setState(
                          () => selectedPaymentProvider = 'btc',
                        ),
                        selectedPaymentProvider: selectedPaymentProvider,
                        paymentType: 'btc',
                      ),
                      // * VISA (Stripe)
                      PaymentProviderButton(
                        logoPaths: [ImagePaths.visa, ImagePaths.mastercard],
                        onChanged: () => setState(
                          () => selectedPaymentProvider = 'stripe',
                        ),
                        selectedPaymentProvider: selectedPaymentProvider,
                        paymentType: 'stripe',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // * Price summary, TOS and Button
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PriceSummary(
                  plans: widget.plans,
                  id: widget.id,
                  isPro: widget.isPro,
                  refCodeSuccessfullyApplied: refCodeSuccessfullyApplied,
                ),
                sessionModel.getCachedPlans((context, cachedPlans, child) {
                  final platinumAvailable = isPlatinumAvailable(cachedPlans);
                  return platinumAvailable
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: 16.0,
                          ),
                          child: CText(
                            'unused_pro_time'.i18n,
                            textAlign: TextAlign.center,
                            style: tsBody2.italic.copiedWith(color: grey5),
                          ),
                        )
                      : Container();
                }),
                Button(
                  disabled: emailFieldKey.currentState?.validate() == false ||
                      refCodeFieldKey.currentState?.validate() == false,
                  text: 'Continue'.i18n,
                  onPressed: () async {
                    await Future.wait(
                      [
                        sessionModel
                            .checkEmailExistence(emailController.value.text)
                            .onError((error, stackTrace) {
                          CDialog.showError(
                            context,
                            error: e,
                            stackTrace: stackTrace,
                            description: error.toString(),
                          );
                        }),
                        resolvePaymentRoute(selectedPaymentProvider),
                      ],
                      eagerError: true,
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> resolvePaymentRoute(String selectedPaymentProvider) async {
    switch (selectedPaymentProvider) {
      case 'stripe':
        await context.pushRoute(
          StripeCheckout(
            plans: widget.plans,
            email: emailController.value.text,
            refCode: refCodeController.value.text,
            refCodeSuccessfullyApplied: refCodeSuccessfullyApplied,
            id: widget.id,
            isPro: widget.isPro,
          ),
        );
        break;
      case 'btc':
        context.loaderOverlay.show();
        await sessionModel
            .getBitcoinEndpoint(
              widget.id,
              emailController.value.text,
            )
            .timeout(
              defaultTimeoutDuration,
              onTimeout: () => onAPIcallTimeout(
                code: 'submitBitcoinTimeout',
                message: 'bitcoin_timeout'.i18n,
              ),
            )
            .then((value) async {
          try {
            final btcPayURL = jsonDecode(value as String)['redirect'];
            await context.pushRoute(
              FullScreenDialogPage(
                widget: PaymentWebview(url: btcPayURL, context: context),
              ),
            );
          } catch (e) {
            print(e);
          }
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
      case 'alipay':
        context.loaderOverlay.show();
        await sessionModel
            .prepareYuansfer(
              widget.id,
              emailController.value.text,
            )
            .timeout(
              defaultTimeoutDuration,
              onTimeout: () => onAPIcallTimeout(
                code: 'yuansferTimeout',
                message: 'alipay_timeout'.i18n,
              ),
            )
            .then((value) async {
          try {
            // TODO: update this
            final alipayURL = jsonDecode(value as String)['redirect'];
            await context.pushRoute(
              FullScreenDialogPage(
                widget: PaymentWebview(url: alipayURL, context: context),
              ),
            );
          } catch (e) {
            print(e);
          }
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
      default:
    }

    ;
  }
}
