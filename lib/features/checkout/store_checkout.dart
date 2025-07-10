import 'package:email_validator/email_validator.dart';
import 'package:lantern/core/service/app_purchase.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/core/utils/utils.dart';

enum _CheckOutState { withEmail, withoutEmail }

@RoutePage(name: 'StoreCheckout')
class StoreCheckout extends StatefulWidget {
  final Plan plan;

  const StoreCheckout({
    required this.plan,
    super.key,
  });

  @override
  State<StoreCheckout> createState() => _StoreCheckoutState();
}

class _StoreCheckoutState extends State<StoreCheckout>
    with SingleTickerProviderStateMixin {
  final emailFieldKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
      formKey: emailFieldKey,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        if (value.isNotEmpty && !EmailValidator.validate(value)) {
          return 'please_enter_a_valid_email_address'.i18n;
        }
        return null;
      });

  _CheckOutState state = _CheckOutState.withEmail;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        resizeToAvoidBottomInset: false,
        title: const AppBarProHeader(),
        body: sessionModel.emailAddress((
          BuildContext context,
          String emailAddress,
          Widget? child,
        ) {
          return Container(
            padding: const EdgeInsetsDirectional.only(top: 24, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(child: CText("Add email address", style: tsHeading1)),
                const SizedBox(
                  height: 16,
                ),
                Form(
                  key: emailFieldKey,
                  child: CTextField(
                    controller: emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    label: 'email'.i18n,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const CAssetImage(path: ImagePaths.email),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 10),
                CText(
                  'email_hint'.i18n,
                  style: tsFloatingLabel.copiedWith(color: grey5),
                ),
                const SizedBox(height: 20.0),
                CText("email_hint_pro".i18n, style: tsBody1),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: Button(
                    text: "continue".i18n,
                    onPressed: () {
                      state = _CheckOutState.withEmail;
                      _validateEmailAndContinue();
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: TextButton(
                    onPressed: () {
                      state = _CheckOutState.withoutEmail;
                      startPurchaseFlow();
                    },
                    child: CText(
                      "continue_without_email".i18n.toUpperCase(),
                      style: tsButtonPink!.copiedWith(
                        color: pink5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
  }

  void _validateEmailAndContinue() {
    if (emailFieldKey.currentState?.validate() == false) {
      return;
    }
    if (emailController.text.isEmpty) {
      showError(context, error: 'please_enter_a_valid_email_address'.i18n);
      return;
    }
    if (Platform.isIOS) {
      showUserConsentDialog();
      return;
    } else {
      startPurchaseFlow();
    }
  }

  void showUserConsentDialog() {
    if (!Platform.isIOS) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    CDialog(
      title: 'What Info We Collect',
      description: "collect_info_message".i18n,
      agreeText: 'accept_and_continue'.i18n,
      dismissText: 'decline'.i18n,
      agreeAction: () async {
        context.maybePop();
        startPurchaseFlow();
        return false;
      },
    ).show(context);
  }

  void startPurchaseFlow() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (Platform.isAndroid) {
      submitPlayPayment();
      return;
    }
    _proceedToCheckoutIOS();
  }

  void submitPlayPayment() async {
    try {
      context.loaderOverlay.show();
      // Await the result of the payment submission.
      await sessionModel.submitPlayPayment(
          widget.plan.id, emailController.value.text);
      context.loaderOverlay.hide();
      resolveRoute();
    } catch (error, stackTrace) {
      // In case of an error, hide the loader and show the error message.
      context.loaderOverlay.hide();
      showError(context, error: error, stackTrace: stackTrace);
    }
  }

  void _proceedToCheckoutIOS() {
    final appPurchase = sl<AppPurchase>();
    final email =
        (state == _CheckOutState.withEmail ? emailController.text : "");
    // Just as safe check
    if (email.isNotEmpty && !EmailValidator.validate(email)) {
      showError(context, error: 'please_enter_a_valid_email_address'.i18n);
      return;
    }
    try {
      context.loaderOverlay.show();
      appPurchase.startPurchase(
        email: email,
        planId: widget.plan.id,
        onSuccess: () {
          context.loaderOverlay.hide();
          resolveRoute();
        },
        onFailure: (error) {
          context.loaderOverlay.hide();
          CDialog.showError(
            context,
            error: error,
            description: error.toString(),
          );
        },
      );
    } catch (error) {
      context.loaderOverlay.hide();
      CDialog.showError(
        context,
        error: error,
        description: error.toString(),
      );
    }
  }

  void resolveRoute() {
    switch (state) {
      case _CheckOutState.withEmail:
        assert(emailController.text.isNotEmpty, "Email should not be empty");
        context.pushRoute(CreateAccountEmail(
          plan: widget.plan,
          email: emailController.text,
        ));
        break;
      case _CheckOutState.withoutEmail:
        context.router.popUntilRoot();
        break;
    }
  }
}
