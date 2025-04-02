import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';

import '../../core/utils/common.dart';

@RoutePage(name: 'SignIn')
class SignIn extends StatefulWidget {
  final AuthFlow authFlow;

  const SignIn({
    super.key,
    this.authFlow = AuthFlow.signIn,
  });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _emailFormKey = GlobalKey<FormState>();
  late final _emailController = CustomTextEditingController(
    formKey: _emailFormKey,
    validator: (value) =>
    EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );
  bool _isPrivacyChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _emailController.text = sessionModel.userEmail.value ?? "";
      });
    });
  }

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
            HeadingText(
              title: widget.authFlow.isReset || widget.authFlow.isUpdateAccount
                  ? 'reset_password'.i18n
                  : 'sign_in'.i18n,
            ),
            const SizedBox(height: 24),
            Form(
              key: _emailFormKey,
              child: CTextField(
                controller: _emailController,
                label: widget.authFlow.isReset || widget.authFlow.isReset
                    ? "lantern_pro_email".i18n
                    : "enter_email".i18n,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: SvgPicture.asset(ImagePaths.email),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            if (Platform.isIOS) ...{
              const SizedBox(height: 24),
              CheckboxListTile(
                value: _isPrivacyChecked,
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() {
                    _isPrivacyChecked = value!;
                  });
                },
                title: CText(
                  'i_agree_to_let_lantern'.i18n,
                  style: tsBody2Short!.copiedWith(
                    color: grey5,
                  ),
                ),
              ),
            },
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Button(
                  disabled: (Platform.isIOS && !_isPrivacyChecked) ||
                      _emailController.text.isEmpty ||
                      _emailFormKey?.currentState?.validate() == false,
                  text: widget.authFlow.isReset ? "next".i18n : 'continue'.i18n,
                  onPressed: onTapResolved),
            ),
            const SizedBox(height: 24),

            if (widget.authFlow.isSignIn &&
                sessionModel.hasUserSignedInNotifier.value == false)
              RichText(
                text: TextSpan(
                  text: 'new_to_lantern'.i18n,
                  style: tsBody1.copyWith(
                      fontWeight: FontWeight.w400, color: grey5),
                  children: [
                    TextSpan(
                      text: "create_account".i18n.toUpperCase(),
                      style: tsBody1.copyWith(
                          fontWeight: FontWeight.w500, color: pink5),
                      recognizer: TapGestureRecognizer()
                        ..onTap = openPlans,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void onTapResolved() {
    switch (widget.authFlow) {
      case AuthFlow.reset:
        resetPasswordFlow();
        break;
      case AuthFlow.updateAccount:
        createAccount();
        break;
      default:
        openCreatePassword();
        break;
    }
  }

  ///Widget methods
  void openCreatePassword() {
    context.pushRoute(SignInPassword(email: _emailController.text));
  }

  Future<void> resetPasswordFlow() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      context.loaderOverlay.show();
      await sessionModel
          .startRecoveryByEmail(_emailController.text.validateEmail);
      context.loaderOverlay.hide();
      openVerification();
    } catch (e) {
      print(e.localizedDescription);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: 'Error while seeding email');
    }
  }

  void openVerification() {
    context.pushRoute(Verification(
      email: _emailController.text,
      authFlow: AuthFlow.reset,
    ));
  }

  void returnToSignIn() {
    context.maybePop();
  }

  Future<void> openPlans() async {
    await context.pushRoute(const PlansPage());
  }

  /// Process for creating account
  /// Create new temp account with random password
  /// Once account is created by pass email verification start forgot password flow
  ///  THis needs to be done to make sure user has legit email
  Future<void> createAccount() async {
    try {
      context.loaderOverlay.show();
      final userTempPass = AppMethods().generatePassword();
      await sessionModel.signUp(
          _emailController.text.validateEmail, userTempPass);
      //start forgot password flow
      forgotPasswordFlow(userTempPass);
    } catch (e, s) {
      mainLogger.e('Error while creating account', error: e, stackTrace: s);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  //forgot password flow
  Future<void> forgotPasswordFlow(String userTempPass) async {
    try {
      final email = _emailController.text.validateEmail;
      //Send verification code to email
      await sessionModel.startRecoveryByEmail(email);
      context.loaderOverlay.hide();
      context.pushRoute(Verification(
          email: _emailController.text,
          authFlow: widget.authFlow,
          tempPassword: userTempPass));
    } catch (e, s) {
      mainLogger.w('Error starting recovery', error: e, stackTrace: s);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }
}
