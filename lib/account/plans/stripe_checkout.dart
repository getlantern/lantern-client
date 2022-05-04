import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:email_validator/email_validator.dart';
import 'package:extended_image/extended_image.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/account/plans/price_summary.dart';
import 'package:lantern/account/plans/tos.dart';
import 'package:lantern/common/common.dart';

class StripeCheckout extends StatefulWidget {
  final List<Map<String, Object>> plans;
  final String email;
  final String? refCode;
  final String id;
  final bool isPro;
  final bool isPlatinum;

  const StripeCheckout({
    required this.plans,
    required this.email,
    this.refCode,
    required this.id,
    required this.isPro,
    required this.isPlatinum,
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
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'Please enter a valid email address'.i18n,
  );

  final creditCardFieldKey = GlobalKey<FormState>();
  late final creditCardController = CustomTextEditingController(
    formKey: creditCardFieldKey,
    validator: (value) =>
        value != null && ccValidator.validateCCNum(value).isValid
            ? null
            : 'Please enter a valid credit card number', // TODO: translations
  );

  final expDateFieldKey = GlobalKey<FormState>();
  late final expDateController = CustomTextEditingController(
    formKey: expDateFieldKey,
    validator: (value) =>
        value != null && ccValidator.validateExpDate(value).isValid
            ? null
            : 'Please enter a valid expiration date'.i18n,
  );

  final cvcFieldKey = GlobalKey<FormState>();
  late final cvcFieldController = CustomTextEditingController(
    formKey: cvcFieldKey,
    validator: (value) => value != null &&
            // only numbers
            RegExp(r'^\d+$').hasMatch(value) &&
            (value.characters.length == 3 || value.characters.length == 4)
        ? null
        : 'Please enter a valid CVC'.i18n,
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
    const copy = 'Complete Purchase'; // TODO: Translation
    return BaseScreen(
      resizeToAvoidBottomInset: false,
      title: 'Lantern ${widget.isPro == true ? 'Pro' : ''} Checkout',
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
            // * Step 2
            // TODO: translations
            const PlanStep(
              stepNum: '3',
              description: 'Checkout',
            ),
            // * Email
            Container(
              padding: const EdgeInsetsDirectional.only(
                top: 8,
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
                  label: 'Credit Card', // TODO: translations
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
                    width: 160,
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
                        label: 'MM/YY', //TODO: translation?
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
                        label: 'CVC',
                        keyboardType: TextInputType.number,
                        prefixIcon: const CAssetImage(path: ImagePaths.lock),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // * Price summary
                PriceSummary(
                  plans: widget.plans,
                  id: widget.id,
                  refCode: widget.refCode,
                  isPro: widget.isPro,
                  isPlatinum: widget.isPlatinum,
                ),
                const TOS(copy: copy),
                Button(
                  disabled: !formIsValid,
                  text: copy, // TODO: translations
                  onPressed: () async {
                    await sessionModel
                        .submitStripe(
                      widget.email,
                      creditCardController.text,
                      expDateController.text,
                      cvcFieldController.text,
                    )
                        .then((value) async {
                      // on success
                      await sessionModel.updateAndCachePlans();
                      await sessionModel.updateAndCacheUserStatus();
                    }).onError((error, stackTrace) {
                      // on failure
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: CText(
                              (error as PlatformException).message ??
                                  error.toString(),
                              style: tsSubtitle1,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: CText(
                                  'Dismiss'.i18n,
                                  style: tsButtonPink,
                                ),
                              ),
                            ],
                          );
                        },
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
