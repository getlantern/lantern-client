// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';

import '../../common/common.dart';

@RoutePage<void>(name: 'CreateAccountEmail')
class CreateAccountEmail extends StatefulWidget {
  final Plan? plan;
  final AuthFlow authFlow;

  const CreateAccountEmail({
    super.key,
    this.plan,
    this.authFlow = AuthFlow.createAccount,
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
    createAccount();
  }

  void emailExistsDialog() {
    showEmailExistsDialog(
      context: context,
      recoverTap: () {},
    );
  }

  /// Process for creating account
  /// Create new temp account with random password
  /// Once account is created by pass email verification start forgot password flow
  Future<void> createAccount() async {
    try {
      context.loaderOverlay.show();
      await sessionModel.signUp(
          _emailController.text.validateEmail, AppMethods().generatePassword());
      //start forgot password flow
      forgotPasswordFlow();
    } catch (e, s) {
      mainLogger.w('Error while creating account', error: e, stackTrace: s);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  //forgot password flow
  Future<void> forgotPasswordFlow() async {
    try {
      final email = _emailController.text.validateEmail;
      //Send verification code to email
      await sessionModel.startRecoveryByEmail(email);
      context.loaderOverlay.hide();
      context.pushRoute(Verification(
          email: email, authFlow: widget.authFlow, plan: widget.plan));
    } catch (e, s) {
      mainLogger.w('Error starting recovery', error: e, stackTrace: s);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }
}
