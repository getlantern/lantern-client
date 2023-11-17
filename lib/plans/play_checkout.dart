import 'package:email_validator/email_validator.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/plans/payment_provider.dart';
import 'package:lantern/plans/plan_details.dart';
import 'package:lantern/plans/utils.dart';

@RoutePage(name: 'PlayCheckout')
class PlayCheckout extends StatefulWidget {
  final Plan plan;
  final bool isPro;

  PlayCheckout({
    required this.plan,
    required this.isPro,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayCheckout> createState() => _PlayCheckoutState();
}

class _PlayCheckoutState extends State<PlayCheckout>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailFieldKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    formKey: emailFieldKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

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
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              end: 16,
              top: 24,
              bottom: 32,
            ),
            child: Column(
              children: [
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
                      autovalidateMode: widget.isPro
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      label: 'email'.i18n,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const CAssetImage(path: ImagePaths.email),
                    ),
                  ),
                ),
                // * Price summary, unused pro time disclaimer, Continue button
                Center(
                  child: Tooltip(
                    message: AppKeys.continueCheckout,
                    child: Button(
                      text: 'submit'.i18n,
                      disabled: emailController.value.text.isEmpty ||
                          emailFieldKey.currentState?.validate() == false,
                      onPressed: submitPayment,
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
  }

  static void showError(
    BuildContext context, {
    Object? error,
    StackTrace? stackTrace,
    String description = '',
  }) {
    if (description.isEmpty) {
      if (error is PlatformException) {
        description = (error).message.toString().i18n;
      } else {
        description = error.toString();
      }
    }
    CDialog.showError(
      context,
      error: e,
      stackTrace: stackTrace,
      description: description,
    );
  }

  void submitPayment() {
    Future.wait(
      [
        sessionModel
            .submitPlayPayment(
          widget.plan.id,
          emailController.value.text,
        )
            .onError((error, stackTrace) {
          showError(
            context,
            error: e,
            stackTrace: stackTrace,
          );
        }),
      ],
      eagerError: true,
    );
  }
}
