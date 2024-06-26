import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/plans/plan_details.dart';
import 'package:lantern/plans/price_summary.dart';
import 'package:lantern/plans/tos.dart';
import 'package:lantern/plans/utils.dart';

@RoutePage(name: 'StripeCheckout')
class StripeCheckout extends StatefulWidget {
  final Plan plan;
  final String email;
  final String? refCode;
  final bool isPro;

  const StripeCheckout({
    required this.plan,
    required this.email,
    this.refCode,
    required this.isPro,
    Key? key,
  }) : super(key: key);

  @override
  State<StripeCheckout> createState() => _StripeCheckoutState();
}

class _StripeCheckoutState extends State<StripeCheckout> {
  final copy = 'Complete Purchase'.i18n;
  final _formKey = GlobalKey<FormState>();
  late final ccValidator = CreditCardValidator();

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
  void dispose() {
    creditCardController.dispose();
    super.dispose();
  }

  Widget checkoutButton() {
    return Tooltip(
      message: AppKeys.checkOut,
      child: Button(
        text: copy,
        onPressed: onCheckoutButtonTap,
      ),
    );
  }

  Future<void> onCheckoutButtonTap() async {
    try {
      context.loaderOverlay.show(widget: spinner);
      await sessionModel.submitStripePayment(
        widget.plan.id,
        widget.email,
        creditCardController.text,
        expDateController.text,
        cvcFieldController.text,
      );
      context.loaderOverlay.hide();
      showSuccessDialog(context, widget.isPro);
    } catch (error, stackTrace) {
      context.loaderOverlay.hide();
      CDialog.showError(
        context,
        error: error,
        stackTrace: stackTrace,
        description: (error as PlatformException)
            .message
            .toString(), // This is coming localized
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      resizeToAvoidBottomInset: false,
      title: 'lantern_pro_checkout'.i18n,
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {
          formIsValid = determineFormIsValid();
        }),
        child: Container(
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
                description: 'checkout'.i18n,
              ),
              // * Credit card number
              Container(
                padding: const EdgeInsetsDirectional.only(
                  top: 16.0,
                  bottom: 16.0,
                ),
                child: CTextField(
                  tooltipMessage: AppKeys.cardNumberKey,
                  controller: creditCardController,
                  // autovalidateMode: AutovalidateMode.disabled,
                  label: 'card_number'.i18n,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  prefixIcon: const CAssetImage(path: ImagePaths.credit_card),
                  inputFormatters: [CreditCardNumberInputFormatter()],
                ),
              ),
              // * Credit card month and expiration
              Container(
                padding: const EdgeInsetsDirectional.only(
                  bottom: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* Expiration
                    Expanded(
                      child: CTextField(
                        tooltipMessage: AppKeys.mmYYKey,
                        maxLines: 1,
                        maxLength: 5,
                        controller: expDateController,
                        autovalidateMode: AutovalidateMode.disabled,
                        label: 'card_expiration'.i18n,
                        inputFormatters: [CreditCardExpirationDateFormatter()],
                        keyboardType: TextInputType.datetime,
                        prefixIcon:
                            const CAssetImage(path: ImagePaths.calendar),
                      ),
                    ),
                    const SizedBox(width: 45),
                    //* CVV
                    Expanded(
                      child: CTextField(
                        tooltipMessage: AppKeys.cvcKey,
                        maxLines: 1,
                        maxLength: 4,
                        controller: cvcFieldController,
                        autovalidateMode: AutovalidateMode.disabled,
                        label: 'cvc'.i18n.toUpperCase(),
                        keyboardType: TextInputType.number,
                        prefixIcon: const CAssetImage(path: ImagePaths.lock),
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
                      plan: widget.plan,
                      refCode: widget.refCode,
                      isPro: widget.isPro,
                    ),
                    TOS(),
                    checkoutButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool determineFormIsValid() {
    // returns true if there is at least one empty field
    final anyFieldsEmpty = creditCardController.value.text.isEmpty ||
        expDateController.value.text.isEmpty ||
        cvcFieldController.value.text.isEmpty;

    // returns true if there is at least one invalid field
    final anyFieldsInvalid =
        creditCardFieldKey.currentState?.validate() == false ||
            expDateFieldKey.currentState?.validate() == false ||
            cvcFieldKey.currentState?.validate() == false;

    return (!anyFieldsEmpty && !anyFieldsInvalid);
  }
}
