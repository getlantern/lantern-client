import 'package:email_validator/email_validator.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/plans/utils.dart';

@RoutePage(name: 'StoreCheckout')
class StoreCheckout extends StatefulWidget {
  final Plan plan;
  final bool isPro;

  const StoreCheckout({
    required this.plan,
    required this.isPro,
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
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        resizeToAvoidBottomInset: false,
        title: 'lantern_pro_checkout'.i18n,

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
                    initialValue: widget.isPro ? emailAddress : '',
                    controller: emailController,
                    autovalidateMode: widget.isPro
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
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
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: TextButton(
                      onPressed: () {},
                      child: CText(
                        "continue_without_email".i18n.toUpperCase(),
                        style: tsButtonPink,
                      )),
                )
              ],
            ),
          );
        }));
  }

  void submitPayment() async {
    try {
      if (emailFieldKey.currentState?.validate() == false) {
        showError(context, error: 'please_enter_a_valid_email_address'.i18n);
      } else {
        context.loaderOverlay.show();
        // Await the result of the payment submission.
        await sessionModel.submitPlayPayment(
            widget.plan.id, emailController.value.text);
        context.loaderOverlay.hide();
        // ignore: use_build_context_synchronously
        showSuccessDialog(context, widget.isPro);
      }
    } catch (error, stackTrace) {
      // In case of an error, hide the loader and show the error message.
      context.loaderOverlay.hide();
      showError(context, error: error, stackTrace: stackTrace);
    }
  }
}
