import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/plans/plan_details.dart';
import 'package:lantern/plans/reseller_checkout.dart';
import 'package:lantern/plans/tos.dart';
import 'package:lantern/plans/utils.dart';

@RoutePage(name: "ResellerCodeCheckoutLegacy")
class ResellerCodeCheckout extends StatefulWidget {
  final bool isPro;

  ResellerCodeCheckout({
    required this.isPro,
    Key? key,
  }) : super(key: key);

  @override
  State<ResellerCodeCheckout> createState() => _ResellerCodeCheckoutState();
}

class _ResellerCodeCheckoutState extends State<ResellerCodeCheckout> {
  final emailFieldKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    formKey: emailFieldKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );

  final resellerCodeFieldKey = GlobalKey<FormState>();
  late final resellerCodeController = CustomTextEditingController(
    formKey: resellerCodeFieldKey,
    validator: (value) => value != null &&
            // only allow letters, numbers and hyphens as well as length excluding dashes should be exactly 25 characters
            // TODO: reject our own referral code
            RegExp(r'^[a-zA-Z0-9-]*$').hasMatch(value) &&
            value.replaceAll('-', '').length == 25
        ? null
        : 'your_activation_code_is_invalid'.i18n,
  );

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = 'register_for_pro'.i18n;
    return sessionModel.emailAddress((
      BuildContext context,
      String emailAddress,
      Widget? child,
    ) {
      return BaseScreen(
        resizeToAvoidBottomInset: false,
        title: 'lantern_pro_checkout'.i18n,
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 24,
            bottom: 24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // * Step 2
              PlanStep(
                stepNum: '2',
                description: 'enter_email_and_activation_code'.i18n,
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
                    autovalidateMode: AutovalidateMode.disabled,
                    label: 'Email'.i18n,
                    onChanged: (value) {
                      setState(() {});
                    },
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const CAssetImage(path: ImagePaths.email),
                  ),
                ),
              ),
              // * Activation code field
              Container(
                padding: const EdgeInsetsDirectional.only(
                  top: 8,
                  bottom: 8,
                ),
                child: Form(
                  key: resellerCodeFieldKey,
                  child: CTextField(
                    maxLength: 25 + 4,
                    //accounting for dashes
                    controller: resellerCodeController,
                    autovalidateMode: AutovalidateMode.disabled,
                    onChanged: (value) {
                      setState(() {});
                    },
                    inputFormatters: [ResellerCodeFormatter()],
                    label: 'Activation Code'.i18n,
                    keyboardType: TextInputType.text,
                    prefixIcon: const CAssetImage(path: ImagePaths.dots),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  const TOS(),
                  SizedBox(height: 16),
                  // * resellerCodeCheckout
                  Button(
                    disabled: emailController.value.text.isEmpty ||
                        emailFieldKey.currentState?.validate() == false ||
                        resellerCodeFieldKey.currentState?.validate() == false,
                    text: copy,
                    onPressed: onRegisterPro,
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  Future<void> onRegisterPro() async {
    try {
      context.loaderOverlay.show();
      Locale locale = Localizations.localeOf(context);
      final format = NumberFormat.simpleCurrency(locale: locale.toString());
      final currencyName = format.currencyName ?? "USD";
      await sessionModel.redeemResellerCode(
        emailController.text,
        currencyName,
        Platform.operatingSystem,
        resellerCodeController.text,
      );
      context.loaderOverlay.hide();
      showSuccessDialog(context, widget.isPro, isReseller: true);
    } catch (error, stackTrace) {
      print(stackTrace);
      appLogger.e(error, stackTrace: stackTrace);
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
}
