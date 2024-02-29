import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';

import '../../common/common.dart';
import '../../core/purchase/app_purchase.dart';
import '../../plans/utils.dart';

@RoutePage<void>(name: 'CreateAccountEmail')
class CreateAccountEmail extends StatefulWidget {
  /// Plan  is used to determine Enable and Disable In App Purchase
  final Plan? plan;

  const CreateAccountEmail({
    super.key,
    this.plan,
  });

  @override
  State<CreateAccountEmail> createState() => _CreateAccountEmailState();
}

class _CreateAccountEmailState extends State<CreateAccountEmail> {
  final _emailFormKey = GlobalKey<FormState>();
  late final _emailController = CustomTextEditingController(
    formKey: _emailFormKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: const AppBarProHeader(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            HeadingText(title: 'create_account'.i18n),
            const SizedBox(height: 24),
            Form(
              key: _emailFormKey,
              child: CTextField(
                controller: _emailController,
                label: "enter_email".i18n,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: SvgPicture.asset(ImagePaths.email),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Button(
                disabled: _emailController.text.isEmpty ||
                    _emailFormKey?.currentState?.validate() == false,
                text: 'continue'.i18n,
                onPressed: onContinue,
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                text: 'already_have_an_account'.i18n,
                style:
                    tsBody1.copyWith(fontWeight: FontWeight.w400, color: grey5),
                children: [
                  TextSpan(
                    text: "sign_in".i18n.toUpperCase(),
                    style: tsBody1.copyWith(
                        fontWeight: FontWeight.w500, color: pink5),
                    recognizer: TapGestureRecognizer()..onTap = openSignInFlow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFormKey.currentState?.dispose();
    super.dispose();
  }

  ///Widget methods

  void openSignInFlow() {
    context.pushRoute(SignIn());
  }

  void onContinue() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (widget.plan != null) {
      startPurchase();
    } else {
      openPassword();
    }
  }

  void openPassword() {
    context.pushRoute(
        CreateAccountPassword(email: _emailController.text.validateEmail));
  }

  void emailExistsDialog() {
    showEmailExistsDialog(
      context: context,
      recoverTap: () {},
    );
  }

  // Purchase flow
  void startPurchase() {
    final appPurchase = sl<AppPurchase>();
    try {
      context.loaderOverlay.show();
      appPurchase.startPurchase(
        email: _emailController.text.validateEmail,
        planId: widget.plan!.id,
        onSuccess: () {
          context.loaderOverlay.hide();
          showSuccessDialog(
            context,
            false,
            barrierDismissible: false,
            onAgree: () {
              openPassword();
            },
          );
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
}
