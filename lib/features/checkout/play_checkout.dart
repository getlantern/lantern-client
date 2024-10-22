import 'package:email_validator/email_validator.dart';
import 'package:lantern/core/service/app_purchase.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/checkout/plan_details.dart';
import 'package:lantern/features/checkout/price_summary.dart';
import 'package:lantern/core/utils/utils.dart';

@RoutePage(name: 'PlayCheckout')
class PlayCheckout extends StatefulWidget {
  final Plan plan;
  final bool isPro;

  const PlayCheckout({
    required this.plan,
    required this.isPro,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayCheckout> createState() => _PlayCheckoutState();
}

class _PlayCheckoutState extends State<PlayCheckout>
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
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              end: 16,
              top: 24,
              bottom: 32,
            ),
            child: Column(
              children: [
                PlanStep(
                  stepNum: '2',
                  description: 'enter_email_to_complete_purchase'.i18n,
                ),
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
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PriceSummary(
                          plan: widget.plan,
                          isPro: widget.isPro,
                        ),
                        Tooltip(
                          message: AppKeys.continueCheckout,
                          child: Button(
                            text: 'Complete Purchase'.i18n,
                            disabled: emailController.value.text.isEmpty,
                            onPressed: onCompletePurchaseTap,
                          ),
                        )
                      ]),
                ),
              ],
            ),
          );
        }));
  }

  void onCompletePurchaseTap() {
    if (Platform.isAndroid) {
      _proceedToCheckoutAndroid();
      return;
    }
    // IOS flow
    _proceedToCheckoutIOS(context);
  }

  void _proceedToCheckoutIOS(BuildContext context) {
    final appPurchase = sl<AppPurchase>();
    try {
      context.loaderOverlay.show();
      appPurchase.startPurchase(
        email: sessionModel.userEmail.value ?? "",
        planId: widget.plan.id,
        onSuccess: () {
          context.loaderOverlay.hide();
          showSuccessDialog(context, widget.isPro);
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
    } catch (e) {
      context.loaderOverlay.hide();
      CDialog.showError(
        context,
        error: e,
        description: e.toString(),
      );
    }
  }

  void _proceedToCheckoutAndroid() async {
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
      context.loaderOverlay.hide();
      CDialog.showError(context, description: error.localizedDescription);

    }
  }
}
