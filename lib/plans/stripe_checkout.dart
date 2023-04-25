import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:email_validator/email_validator.dart';
import 'package:lantern/plans/plans.dart';
import 'package:lantern/plans/price_summary.dart';
import 'package:lantern/plans/tos.dart';
import 'package:lantern/common/common.dart';

class StripeCheckout extends StatefulWidget {
  final List<Map<String, dynamic>> plans;
  final String email;
  final String? refCode;
  final String id;
  final bool isPro;

  const StripeCheckout({
    required this.plans,
    required this.email,
    this.refCode,
    required this.id,
    required this.isPro,
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
          start: 16,
          end: 16,
          top: 24,
          bottom: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // * Step 3
            PlanStep(
              stepNum: '3',
              description: 'Checkout'.i18n,
            ),
            // * Email
            Container(
              padding: const EdgeInsetsDirectional.only(
                top: 16,
                bottom: 8,
              ),
              child: Form(
                onChanged: () => setState(() {
                  formIsValid = determineFormIsValid();
                }),
                key: emailFieldKey,
                child: CTextField(
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
                  prefixIcon: const CAssetImage(path: ImagePaths.credit_card),
                ),
              ),
            ),
            // * Credit card month and expiration
            Container(
              padding: const EdgeInsetsDirectional.only(
                top: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //* Expiration
                  Container(
                    width: 150,
                    child: Form(
                      onChanged: () => setState(() {
                        formIsValid = determineFormIsValid();
                      }),
                      key: expDateFieldKey,
                      child: CTextField(
                        maxLines: 1,
                        maxLength: 5,
                        controller: expDateController,
                        autovalidateMode: AutovalidateMode.disabled,
                        label: 'card_expiration'.i18n,
                        keyboardType: TextInputType.datetime,
                        prefixIcon:
                            const CAssetImage(path: ImagePaths.calendar),
                      ),
                    ),
                  ),
                  //* CVV
                  Container(
                    width: 150,
                    child: Form(
                      onChanged: () => setState(() {
                        formIsValid = determineFormIsValid();
                      }),
                      key: cvcFieldKey,
                      child: CTextField(
                        maxLines: 1,
                        maxLength: 4,
                        controller: cvcFieldController,
                        autovalidateMode: AutovalidateMode.disabled,
                        label: 'cvc'.i18n.toUpperCase(),
                        keyboardType: TextInputType.number,
                        prefixIcon: const CAssetImage(path: ImagePaths.lock),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // * Price summary
                  PriceSummary(
                    plans: widget.plans,
                    id: widget.id,
                    refCode: widget.refCode,
                    isPro: widget.isPro,
                  ),
                  TOS(copy: copy),
                  Button(
                    disabled: !formIsValid,
                    text: copy,
                    onPressed: () async {
                      context.loaderOverlay.show();
                      await sessionModel
                          .submitStripePayment(
                            widget.email,
                            creditCardController.text,
                            expDateController.text,
                            cvcFieldController.text,
                          )
                          .timeout(
                            defaultTimeoutDuration,
                            onTimeout: () => onAPIcallTimeout(
                              code: 'submitStripeTimeout',
                              message: 'stripe_timeout'.i18n,
                            ),
                          )
                          .then((value) async {
                        context.loaderOverlay.hide();
                        CDialog.showInfo(
                          context,
                          iconPath: ImagePaths.lantern_logo,
                          size: 80,
                          title: 'renewal_success'.i18n,
                          description: 'stripe_success'.i18n,
                          actionLabel: 'Continue'.i18n,
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
            ),
          ],
        ),
      ),
    );
  }

  bool determineFormIsValid() {
    // returns true if there is at least one empty field
    final anyFieldsEmpty = emailController.value.text.isEmpty ||
        creditCardController.value.text.isEmpty ||
        expDateController.value.text.isEmpty ||
        cvcFieldController.value.text.isEmpty;

    // returns true if there is at least one invalid field
    final anyFieldsInvalid = !emailFieldKey.currentState?.validate() ||
        !creditCardFieldKey.currentState?.validate() ||
        !expDateFieldKey.currentState?.validate() ||
        !cvcFieldKey.currentState?.validate();

    return (!anyFieldsEmpty && !anyFieldsInvalid);
  }
}
