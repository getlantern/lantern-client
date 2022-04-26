import 'package:email_validator/email_validator.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/account/plans/price_summary.dart';
import 'package:lantern/account/plans/tos.dart';
import 'package:lantern/common/common.dart';

class StripeCheckout extends StatefulWidget {
  final String email;
  // TODO: temp workaround
  final bool? isCN;
  final bool? isFree;
  final bool? isPro;
  final bool? isPlatinum;

  const StripeCheckout({
    required this.email,
    Key? key,
    this.isCN,
    this.isFree,
    this.isPro,
    this.isPlatinum,
  }) : super(key: key);

  @override
  State<StripeCheckout> createState() => _StripeCheckoutState();
}

class _StripeCheckoutState extends State<StripeCheckout> {
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
    // TODO: consolidate regex expressions in a regex constants file
    // via https://regexpattern.com/credit-card-number/
    validator: (value) => value != null &&
            RegExp(r'/^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$/')
                .hasMatch(value)
        ? null
        : 'Please enter a valid credit card number', // TODO: translations
  );

  final expDateFieldKey = GlobalKey<FormState>();
  late final expDateController = CustomTextEditingController(
    formKey: expDateFieldKey,
    // TODO: consolidate regex expressions in a regex constants file
    validator: (value) => value != null &&
            RegExp(r'/^(0[1-9]|1[0-2])\/?([0-9]{4}|[0-9]{2})$/').hasMatch(value)
        ? null
        : 'Please enter a valid credit card number'.i18n,
  );

  final cvvFieldKey = GlobalKey<FormState>();
  late final cvvFieldController = CustomTextEditingController(
    formKey: cvvFieldKey,
    validator: (value) => value != null && value.characters.length == 3
        ? null
        : 'Please enter a valid credit card number'.i18n,
  );

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
              child: CTextField(
                initialValue: widget.email,
                controller: emailController,
                autovalidateMode: AutovalidateMode.disabled,
                label: 'Email'.i18n,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const CAssetImage(path: ImagePaths.email),
              ),
            ),
            // * Credit card number
            Container(
              padding: const EdgeInsetsDirectional.only(
                top: 8,
                bottom: 8,
              ),
              child: CTextField(
                controller: creditCardController,
                autovalidateMode: AutovalidateMode.disabled,
                label: 'Credit Card', // TODO: translations
                keyboardType: TextInputType.number,
                prefixIcon: const CAssetImage(path: ImagePaths.credit_card),
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
                    child: CTextField(
                      maxLines: 1,
                      controller: expDateController,
                      autovalidateMode: AutovalidateMode.disabled,
                      label: 'MM/YY',
                      keyboardType: TextInputType.datetime,
                      prefixIcon: const CAssetImage(path: ImagePaths.calendar),
                    ),
                  ),
                  //* CVV
                  Container(
                    width: 160,
                    child: CTextField(
                      maxLines: 1,
                      controller: cvvFieldController,
                      autovalidateMode: AutovalidateMode.disabled,
                      label: 'CVC',
                      keyboardType: TextInputType.number,
                      prefixIcon: const CAssetImage(path: ImagePaths.lock),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // * Price summary
                    PriceSummary(
                      isCN: widget.isCN,
                      isFree: widget.isFree,
                      isPro: widget.isPro,
                      isPlatinum: widget.isPlatinum,
                      price: '10',
                    ),
                    const TOS(copy: copy),
                    // TODO: translations
                    // TODO: pin to bottom
                    // TODO: integrate Flutter Stripe SDK
                    Button(text: copy, onPressed: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
