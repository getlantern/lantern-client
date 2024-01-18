import '../../common/common.dart';

@RoutePage<void>(name: 'Verification')
class Verification extends StatefulWidget {
  final String email;
  final AuthFlow authFlow;

  const Verification({
    super.key,
    required this.email,
    this.authFlow = AuthFlow.reset,
  });

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final pinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.authFlow.isCreateAccount || widget.authFlow.isVerifyEmail
          ? 'confirm_email'.i18n
          : 'reset_password'.i18n,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const LogoWithText(),
              const SizedBox(height: 24),
              CText(
                "enter_confirmation_code".i18n.toUpperCase(),
                style: tsOverline,
              ),
              const SizedBox(height: 8),
              PinField(
                length: 6,
                controller: pinCodeController,
                onDone: onDone,
              ),
              LabeledDivider(
                padding: const EdgeInsetsDirectional.only(top: 24, bottom: 10),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: CText(
                  'confirmation_code_msg'.i18n.replaceAll('XX', widget.email),
                  style: tsBody1,
                ),
              ),
              const SizedBox(height: 24),
              Button(
                text: "resend_confirmation_code".i18n,
                onPressed: resendConfirmationCode,
              ),
              const SizedBox(height: 14),
              if (!widget.authFlow.isVerifyEmail)
                AppTextButton(
                  text: 'change_email'.i18n.toUpperCase(),
                  onPressed: () {
                    context.popRoute();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }


  /// widget methods
  Future<void> resendConfirmationCode() async {
    try {
      context.loaderOverlay.show();
      await sessionModel.signUpEmailResendCode(widget.email);
      context.loaderOverlay.hide();
      AppMethods.showToast('email_resend_message'.i18n);
    } catch (e) {
      mainLogger.e(e);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  void onDone(String code) {
    switch (widget.authFlow) {
      case AuthFlow.createAccount:
        _verifyEmail(code);
        break;
      case AuthFlow.reset:
        openResetPassword(code);
        break;
      case AuthFlow.signIn:
        context.router.popUntilRoot();
      case AuthFlow.verifyEmail:
        _verifyEmail(code);
        break;
    }
  }

  void openResetPassword(String code) {
    context.pushRoute(ResetPassword(email: widget.email, code: code));
  }

  void _verifyEmail(String code) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.signupEmailConfirmation(widget.email, code);
      context.loaderOverlay.hide();
      if (widget.authFlow.isCreateAccount) {
        CDialog.successDialog(
          context: context,
          title: "email_has_been_verified".i18n,
          description: "email_has_been_verified_message".i18n,
          successCallback: () {
            context.router.popUntilRoot();
          },
        );
      } else {
        context.router.pop();
      }
      sessionModel.hasAccountVerified.value = true;
    } catch (e) {
      mainLogger.e(e);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }
}
