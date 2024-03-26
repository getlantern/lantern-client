import 'package:email_validator/email_validator.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/common_desktop.dart';
import 'package:lantern/common/ui/app_webview.dart';
import 'package:lantern/plans/payment_provider.dart';
import 'package:lantern/plans/plan_details.dart';
import 'package:lantern/plans/utils.dart';
import 'package:intl/intl.dart';

@RoutePage(name: 'Checkout')
class Checkout extends StatefulWidget {
  final Plan plan;
  final bool isPro;

  Checkout({
    required this.plan,
    required this.isPro,
    Key? key,
  }) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout>
    with SingleTickerProviderStateMixin {
  bool showMoreOptions = false;
  bool showContinueButton = false;
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

  void selectPaymentProvider(Providers provider) {
    setState(
      () => selectedPaymentProvider = provider,
    );
  }

  List<Widget> desktopPaymentOptions() {
    var widgets = <Widget>[];
    widgets.add(
      PaymentProvider(
        logoPaths: [
          ImagePaths.visa,
          ImagePaths.mastercard,
          ImagePaths.unionpay
        ],
        onChanged: () => selectPaymentProvider(Providers.stripe),
        selectedPaymentProvider: selectedPaymentProvider!,
        paymentType: Providers.stripe,
      ),
    );
    return widgets;
  }

  List<Widget> paymentOptions(
    Iterable<PathAndValue<PaymentMethod>> paymentMethods,
  ) {
    var widgets = <Widget>[];
    for (final paymentMethod in paymentMethods) {
      if (widgets.length == 2) {
        widgets.add(options());
        if (!showMoreOptions) break;
      }
      for (final provider in paymentMethod.value.providers) {
        widgets.add(
          PaymentProvider(
            logoPaths: provider.logoUrls,
            onChanged: () => selectPaymentProvider(Providers.stripe),
            selectedPaymentProvider: selectedPaymentProvider!,
            paymentType: provider.name.toPaymentEnum(),
            useNetwork: true,
          ),
        );
      }
    }
    return widgets;
  }

  Future<void> checkProUser() async {
    final res = await ffiProUser();
    if (!widget.isPro && res.toDartString() == "true") {
      // show success dialog if user becomes Pro during browser session
      showSuccessDialog(context, widget.isPro);
    }
  }

  Future<void> openDesktopWebview() async {
    try {
      String os = Platform.operatingSystem;
      Locale locale = Localizations.localeOf(context);
      final format = NumberFormat.simpleCurrency(locale: locale.toString());
      final currencyName = format.currencyName ?? "USD";
      final redirectUrl = await sessionModel.paymentRedirect(
        widget.plan.id,
        currencyName,
        emailController.text,
        "stripe",
        os,
      );
      switch (Platform.operatingSystem) {
        case 'windows':
          await AppBrowser.openWindowsWebview(redirectUrl);
          break;
        case 'macos':
          final browser = AppBrowser(onClose: checkProUser);
          await browser.openMacWebview(redirectUrl);
          break;
        default:
          await context.pushRoute(AppWebview(url: redirectUrl));
      }
    } catch (e) {
      showError(context, error: e);
    }
  }

  Future<void> resolvePaymentRoute() async {
    switch (selectedPaymentProvider!) {
      case Providers.stripe:
        // * Stripe selected
        if (isDesktop()) {
          await openDesktopWebview();
          return;
        }
        await context.pushRoute(
          StripeCheckout(
            email: emailController.text,
            refCode: refCodeController.text,
            plan: widget.plan,
            isPro: widget.isPro,
          ),
        );
        break;
      case Providers.btcpay:
        // * BTC payment selected
        context.loaderOverlay.show();
        await sessionModel
            .submitBitcoinPayment(
              widget.plan.id,
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
          showError(context, error: error, stackTrace: stackTrace);
        });
        break;
      case Providers.freekassa:
        var strs = widget.plan.id.split('-');
        if (strs.length < 2) break;
        var currency = strs[1];
        var currencyCost = widget.plan.price[currency];
        if (currencyCost == null) break;
        await sessionModel.submitFreekassa(
          emailController.text,
          widget.plan.id,
          currencyCost.toString(),
        );
        break;
    }
  }

  bool enableContinueButton() {
    final isEmailValid = !emailController.value.text.isEmpty &&
        emailFieldKey.currentState!.validate();
    if (!isRefCodeFieldShowing || refCodeController.text.isEmpty) {
      return isEmailValid;
    }
    return isEmailValid && refCodeFieldKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        resizeToAvoidBottomInset: false,
        title: 'lantern_pro_checkout'.i18n,
        body: sessionModel.paymentMethods(
          builder: (
            context,
            Iterable<PathAndValue<PaymentMethod>> paymentMethods,
            Widget? child,
          ) {
            defaultProviderIfNecessary(paymentMethods.toList());
            return sessionModel.emailAddress((
              BuildContext context,
              String emailAddress,
              Widget? child,
            ) {
              return Container(
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  top: 24,
                  bottom: 32,
                ),
                child: Column(
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
                          initialValue: widget.isPro ? emailAddress : '',
                          controller: emailController,
                          onChanged: (text) {
                            setState(() {
                              showContinueButton = enableContinueButton();
                            });
                          },
                          autovalidateMode: widget.isPro
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          contentPadding: const EdgeInsetsDirectional.only(
                            top: 8.0,
                            bottom: 8.0,
                          ),
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
                                  controller: refCodeController,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  contentPadding:
                                      const EdgeInsetsDirectional.only(
                                    top: 8.0,
                                    bottom: 8.0,
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      showContinueButton =
                                          enableContinueButton();
                                    });
                                  },
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  label: 'referral_code'.i18n,
                                  keyboardType: TextInputType.text,
                                  prefixIcon:
                                      const CAssetImage(path: ImagePaths.star),
                                ),
                              ),
                            ),
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
                        children: Platform.isAndroid
                            ? paymentOptions(paymentMethods)
                            : desktopPaymentOptions(),
                      ),
                    ),
                    // * Price summary, unused pro time disclaimer, Continue button

                    Center(
                      child: Tooltip(
                        message: AppKeys.continueCheckout,
                        child: Button(
                          text: 'continue'.i18n,
                          disabled: !showContinueButton,
                          onPressed: onContinueTapped,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ));
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

  void onContinueTapped() {
    var refCode = refCodeController.value;
    Future.wait(
      [
        sessionModel
            .checkEmailExists(
          emailController.value.text,
        )
            .onError((error, stackTrace) {
          showError(
            context,
            error: error,
            stackTrace: stackTrace,
          );
        }),
        if (refCode.text.isNotEmpty)
          sessionModel
              .applyRefCode(
                refCode.text,
              )
              .then((value) => resolvePaymentRoute())
              .onError((error, stackTrace) {
            refCodeController.error =
                'invalid_or_incomplete_referral_code'.i18n;
          })
        else
          resolvePaymentRoute(),
      ],
      eagerError: true,
    );
  }
}
