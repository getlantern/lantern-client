import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:email_validator/email_validator.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/account/plans/price_summary.dart';
import 'package:lantern/account/plans/plan_utils.dart';
import 'package:lantern/account/plans/tos.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/common/ui/custom/text_input_formatter.dart';

import 'purchase_success_dialog.dart';

class StripeCheckout extends StatefulWidget {
  final List<Map<String, dynamic>> plans;
  final String email;
  final String? refCode;
  final String id;
  final bool isPro;
  final bool refCodeSuccessfullyApplied;

  const StripeCheckout({
    required this.plans,
    required this.email,
    this.refCode,
    required this.id,
    required this.isPro,
    required this.refCodeSuccessfullyApplied,
    Key? key,
  }) : super(key: key);

  @override
  State<StripeCheckout> createState() => _StripeCheckoutState();
}

class _StripeCheckoutState extends State<StripeCheckout> {
  late final ccValidator = CreditCardValidator();

  final emailFieldKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    formKey: emailFieldKey,
    validator: (value) =>
        EmailValidator.validate(value ?? '') ? null : 'invalid_email'.i18n,
  );

  final creditCardFieldKey = GlobalKey<FormState>();
  late final creditCardController = CustomTextEditingController(
    formKey: creditCardFieldKey,
    validator: (value) =>
        value != null && ccValidator.validateCCNum(value).isValid
            ? null
            : 'invalid_card'.i18n,
  );

  final expDateFieldKey = GlobalKey<FormState>();
  late final expDateController = CustomTextEditingController(
    formKey: expDateFieldKey,
    validator: (value) =>
        value != null && ccValidator.validateExpDate(value).isValid
            ? null
            : 'invalid_expiration'.i18n,
  );

  final cvcFieldKey = GlobalKey<FormState>();
  late final cvcFieldController = CustomTextEditingController(
    formKey: cvcFieldKey,
    validator: (value) => value != null &&
            // only numbers
            RegExp(r'^\d+$').hasMatch(value) &&
            (value.characters.length == 3 || value.characters.length == 4)
        ? null
        : 'invalid_cvc'.i18n,
  );

  var formIsValid = false;
  var keyDown;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    creditCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = 'Complete Purchase'.i18n;
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
                PlanStep(
                  stepNum: '3',
                  description: 'Checkout'.i18n,
                ),
                // * Email
                Container(
                  padding: const EdgeInsetsDirectional.only(
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: Form(
                    onChanged: () => setState(() {
                      formIsValid = determineFormIsValid();
                    }),
                    key: emailFieldKey,
                    child: CTextField(
                      enabled: widget.email.isEmpty,
                      initialValue: widget.email,
                      controller: emailController,
                      autovalidateMode: AutovalidateMode.disabled,
                      label: 'Email'.i18n,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const CAssetImage(path: ImagePaths.email),
                    ),
                  ),
                ),
                // * Credit card number
                Container(
                  padding: const EdgeInsetsDirectional.only(
                    top: 8,
                    bottom: 8,
                  ),
                  child: Form(
                    onChanged: () => setState(() {
                      formIsValid = determineFormIsValid();
                    }),
                    key: creditCardFieldKey,
                    child: CTextField(
                      controller: creditCardController,
                      autovalidateMode: AutovalidateMode.disabled,
                      label: 'card_number'.i18n,
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      maxLength: 19,
                      hintText: 'XXXX XXXX XXXX XXXX',
                      prefixIcon:
                          const CAssetImage(path: ImagePaths.credit_card),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CTextInputFormatter(separator: ' ', cutoff: 4),
                      ],
                    ),
                  ),
                ),
                // * Date and expiration
                Container(
                  padding: const EdgeInsetsDirectional.only(
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //* Expiration
                      Flexible(
                        child: Form(
                          onChanged: () => setState(() {
                            formIsValid = determineFormIsValid();
                          }),
                          key: expDateFieldKey,
                          child: CTextField(
                            contentPadding: EdgeInsetsDirectional.zero,
                            maxLines: 1,
                            maxLength: 5,
                            controller: expDateController,
                            autovalidateMode: AutovalidateMode.disabled,
                            label: 'card_expiration'.i18n,
                            keyboardType: TextInputType.number,
                            prefixIcon: const CAssetImage(
                              path: ImagePaths.calendar,
                            ),
                            hintText: 'XX/XX',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CTextInputFormatter(separator: '/', cutoff: 2),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsetsDirectional.all(16.0),
                      ),
                      //* CVV
                      Flexible(
                        child: Form(
                          onChanged: () => setState(() {
                            formIsValid = determineFormIsValid();
                          }),
                          key: cvcFieldKey,
                          child: CTextField(
                            contentPadding: EdgeInsetsDirectional.zero,
                            maxLines: 1,
                            maxLength: 4,
                            controller: cvcFieldController,
                            autovalidateMode: AutovalidateMode.disabled,
                            label: 'cvc'.i18n.toUpperCase(),
                            keyboardType: TextInputType.number,
                            prefixIcon:
                                const CAssetImage(path: ImagePaths.lock),
                            hintText: 'XXX',
                          ),
                        ),
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
                  refCode: widget.refCode,
                  isPro: widget.isPro,
                  refCodeSuccessfullyApplied: widget.refCodeSuccessfullyApplied,
                ),
                TOS(copy: copy),
                Button(
                  disabled: !formIsValid,
                  text: copy,
                  onPressed: () async {
                    context.loaderOverlay.show();
                    await sessionModel
                        .submitStripe(
                      widget.email,
                      creditCardController.value.text,
                      expDateController.value.text,
                      cvcFieldController.value.text,
                      widget.id,
                    )
                        // // Let's comment this out for now, to avoid timeout conflicts from Stripe's side
                        // .timeout(
                        //   defaultTimeoutDuration,
                        //   onTimeout: () => onAPIcallTimeout(
                        //     code: 'submitStripeTimeout',
                        //     message: 'stripe_timeout'.i18n,
                        //   ),
                        // )
                        .then((value) {
                      context.loaderOverlay.hide();
                      showDialog(
                        context: context,
                        builder: (context) => sessionModel.getCachedUserLevel(
                          (context, userLevel, child) =>
                              sessionModel.getUpgradeOrRenewal(
                            (context, renewalOrUpgrade, child) =>
                                PurchaseSuccessDialog(
                              title: getPurchaseDialogTitle(
                                userLevel,
                                renewalOrUpgrade,
                              ),
                              description: getPurchaseDialogText(
                                userLevel,
                                renewalOrUpgrade,
                              ),
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
                            .toString(), // This is coming localized
                      );
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // returns true if we can submit
  bool determineFormIsValid() {
    // returns true if there is at least one empty field
    final anyFieldsEmpty = emailController.value.text.isEmpty ||
        creditCardController.value.text.isEmpty ||
        expDateController.value.text.isEmpty ||
        cvcFieldController.value.text.isEmpty;

    // returns true if there is at least one invalid field
    final anyFieldsInvalid = emailFieldKey.currentState?.validate() == false ||
        creditCardFieldKey.currentState?.validate() == false ||
        expDateFieldKey.currentState?.validate() == false ||
        cvcFieldKey.currentState?.validate() == false;

    return (!anyFieldsEmpty && !anyFieldsInvalid);
  }
}
