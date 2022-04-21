import 'package:email_validator/email_validator.dart';
import 'package:lantern/account/plans/plan_step.dart';
import 'package:lantern/common/common.dart';

class Checkout extends StatelessWidget {
  Checkout({Key? key}) : super(key: key);
  final formKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    formKey: formKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'Please enter a valid email address'.i18n,
  );

  @override
  Widget build(BuildContext context) {
    var referralCode = '';
    var isPromoFieldShowing = false;
    return BaseScreen(
      // TODO: this depends on isCN
      // TODO: translations
      title: 'Lantern Pro Checkout',
      body: StatefulBuilder(
          builder: (context, setState) => Container(
                padding: const EdgeInsetsDirectional.only(
                  start: 32,
                  end: 32,
                  top: 24,
                  bottom: 32,
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
                    // * Promo Code
                    buildPromoCodeField(
                      isPromoFieldShowing,
                      setState,
                      context,
                    ),
                    // * Step 3
                    const PlanStep(
                      stepNum: '3',
                      description: 'Choose Payment Method',
                    ), // TODO: translations
                    //* Payment options
                    Container(
                      padding:
                          const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 64,
                            width: 200,
                            margin:
                                const EdgeInsetsDirectional.only(bottom: 16),
                            child: OutlinedButton(
                              onPressed: () {},
                              child: Text('VISA'),
                            ),
                          ),
                          Container(
                            height: 64,
                            width: 200,
                            child: OutlinedButton(
                              onPressed: () {},
                              child: Text('BTC'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // * Continue to Payment
                    Button(
                      text: 'Does not work yet',
                      onPressed: () {
                        LanternNavigator.startScreen(
                          LanternNavigator.SCREEN_CHECKOUT_VIA_STRIPE,
                        );
                      },
                    ),
                  ],
                ),
              )),
    );
  }

  Container buildPromoCodeField(
    bool isPromoFieldShowing,
    Function setState,
    BuildContext context,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsetsDirectional.only(
        top: 8,
        bottom: 16,
      ),
      child: isPromoFieldShowing
          ? CTextField(
              controller: emailController,
              autovalidateMode: AutovalidateMode.disabled,
              label: 'Email'.i18n,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const CAssetImage(path: ImagePaths.email),
            )
          : GestureDetector(
              onTap: () =>
                  setState(() => isPromoFieldShowing = !isPromoFieldShowing),
              child: CText('+ Add Referral code', style: tsBody1),
            ),
    );
  }
}
