import 'package:email_validator/email_validator.dart';
import 'package:lantern/account/plans/payment_provider_button.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/account/plans/price_summary.dart';
import 'package:lantern/common/common.dart';

class Checkout extends StatefulWidget {
  final bool? isCN;
  final bool? isFree;
  final bool? isPro;
  final bool? isPlatinum;

  Checkout({this.isCN, Key? key, this.isFree, this.isPro, this.isPlatinum})
      : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final emailFieldKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    formKey: emailFieldKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'Please enter a valid email address'.i18n,
  );

  final promoFieldKey = GlobalKey<FormState>();
  late final promoFieldController = CustomTextEditingController(
    formKey: promoFieldKey,
    validator: (value) =>
        // only allow letters and numbers
        value != null && RegExp(r'^[a-zA-Z0-9]*$').hasMatch(value)
            ? null
            : 'Please enter a valid promo code'.i18n,
  );

  final referralCode = '';
  var isPromoFieldShowing = false;
  // TODO: this should not be here
  final paymentProviders = [
    'stripe',
    'btc',
  ];
  var selectedPaymentProvider = 'stripe';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    promoFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      // TODO: translations
      title: 'Lantern Pro Checkout',
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          top: 24,
          bottom: 24,
        ),
        child: Column(
          children: [
            // * Step 2
            const PlanStep(
              stepNum: '2',
              description: 'Enter email',
            ), // TODO: translations
            // * Email field
            Container(
              padding: const EdgeInsetsDirectional.only(
                top: 8,
                bottom: 8,
              ),
              child: CTextField(
                controller: emailController,
                autovalidateMode: AutovalidateMode.disabled,
                label: 'Email'.i18n,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const CAssetImage(path: ImagePaths.email),
              ),
            ),
            // * Promo Code field
            Visibility(
              visible: isPromoFieldShowing,
              child: Container(
                padding: const EdgeInsetsDirectional.only(
                  top: 8,
                  bottom: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: CTextField(
                        controller: promoFieldController,
                        autovalidateMode: AutovalidateMode.disabled,
                        label: 'Promo code', // TODO: translations
                        keyboardType: TextInputType.text,
                        prefixIcon: const CAssetImage(path: ImagePaths.star),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 16.0,
                        end: 16.0,
                      ),
                      child: CInkWell(
                        onTap: () {}, // TODO: submit promo code
                        child: CText(
                          'Apply'.toUpperCase(), // TODO: translations
                          style: tsButtonPink,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // * Add promo code
            Visibility(
              visible: !isPromoFieldShowing,
              child: GestureDetector(
                onTap: () async => setState(() => isPromoFieldShowing = true),
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
            const PlanStep(
              stepNum: '3',
              description: 'Choose Payment Method',
            ), // TODO: translations
            //* Payment options
            Flexible(
              child: Container(
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
            ),
            // * Price summary
            PriceSummary(
              isCN: widget.isCN,
              isFree: widget.isFree,
              isPro: widget.isPro,
              isPlatinum: widget.isPlatinum,
              price: '\$10',
            ),
            // * Continue to Payment
            // TODO: pin to bottom
            Button(
              text: 'Continue',
              onPressed: () async =>
                  await context.pushRoute(StripeCheckout(email: 'bla@bla.com')),
            ),
          ],
        ),
      ),
    );
  }
}
