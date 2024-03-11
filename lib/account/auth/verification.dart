// ignore_for_file: use_build_context_synchronously

import 'package:lantern/core/purchase/app_purchase.dart';

import '../../common/common.dart';
import 'change_email.dart';

@RoutePage<void>(name: 'Verification')
class Verification extends StatefulWidget {
  final String email;
  final AuthFlow authFlow;
  final Plan? plan;
  final ChangeEmailPageArgs? changeEmailArgs;

  const Verification({
    super.key,
    required this.email,
    this.authFlow = AuthFlow.reset,
    this.changeEmailArgs,
    this.plan,
  });

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final pinCodeController = TextEditingController();

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              HeadingText(
                title: widget.authFlow.isCreateAccount ||
                        widget.authFlow.isVerifyEmail
                    ? 'confirm_email'.i18n
                    : 'reset_password'.i18n,
              ),
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
              if (!widget.authFlow.isVerifyEmail &&
                  !widget.authFlow.isCreateAccount&&!widget.authFlow.isproCodeActivation)
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
    switch (widget.authFlow) {
      case AuthFlow.createAccount:
        resendResetEmailVerificationCode();
        break;
      case AuthFlow.reset:
        resendResetEmailVerificationCode();
        break;
      case AuthFlow.verifyEmail:

        /// This should be handled when account created
        break;
      case AuthFlow.proCodeActivation:
        resendResetEmailVerificationCode();
        break;
      case AuthFlow.changeEmail:
        resendChangeEmailVerificationCode();
      case AuthFlow.signIn:

      /// there is no verification flow for sign in
    }
  }

  Future<void> resendCreateAccountVerificationCode() async {
    try {
      context.loaderOverlay.show();
      await sessionModel.signUpEmailResendCode(widget.email);
      context.loaderOverlay.hide();
      AppMethods.showToast('email_resend_message'.i18n);
    } catch (e, s) {
      mainLogger.e('Error while resending code', error: e, stackTrace: s);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  Future<void> resendChangeEmailVerificationCode() async {
    assert(widget.changeEmailArgs != null, 'ChangeEmailArgs is null');
    try {
      final emailArgs = widget.changeEmailArgs!;
      context.loaderOverlay.show();
      await sessionModel.startChangeEmail(
          emailArgs.email, emailArgs.newEmail, emailArgs.password);
      context.loaderOverlay.hide();
      AppMethods.showToast('email_resend_message'.i18n);
    } catch (e, s) {
      mainLogger.e('Error while resending code', error: e, stackTrace: s);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  Future<void> resendResetEmailVerificationCode() async {
    try {
      context.loaderOverlay.show();
      await sessionModel.startRecoveryByEmail(widget.email);
      context.loaderOverlay.hide();
      AppMethods.showToast('email_resend_message'.i18n);
    } catch (e, s) {
      mainLogger.e('Error while resending code', error: e, stackTrace: s);
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

        ///While sign in there will be no verification flow
        throw Exception('Invalid AuthFlow');
      case AuthFlow.verifyEmail:
        _verifyEmail(code);
        break;
      case AuthFlow.proCodeActivation:
        _verifyEmail(code);
      case AuthFlow.changeEmail:
        _changeEmail(code);
    }
  }

  void openResetPassword(String code) {
    context.pushRoute(ResetPassword(email: widget.email, code: code));
  }

  void _verifyEmail(String code) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.validateRecoveryCode(widget.email, code);
      sessionModel.hasAccountVerified.value = true;
      context.loaderOverlay.hide();
      resolveRoute();
    } catch (e) {
      mainLogger.e(e);
      context.loaderOverlay.hide();
      pinCodeController.clear();
      CDialog.showError(
        context,
        description: e.localizedDescription,
      );
    }
  }

  Future<void> _changeEmail(String code) async {
    assert(widget.changeEmailArgs != null, 'ChangeEmailArgs is null');
    final emailArgs = widget.changeEmailArgs!;
    mainLogger.d(
        "email ${emailArgs.email} newEmail ${emailArgs.newEmail} password ${emailArgs.password} code ${pinCodeController.text}");
    try {
      context.loaderOverlay.show();
      await sessionModel.completeChangeEmail(emailArgs.email,
          emailArgs.newEmail, emailArgs.password, pinCodeController.text);
      context.loaderOverlay.hide();
      CDialog.successDialog(
        context: context,
        title: 'email_has_been_updated'.i18n,
        description: 'email_has_been_updated_message'.i18n,
        successCallback: () {
          //Once email changed, pop to account management
          context.router.popUntil(
              (route) => route.settings.name == AccountManagement.name);
        },
      );
    } catch (e) {
      mainLogger.e(e);
      context.loaderOverlay.hide();
      pinCodeController.clear();
      CDialog.showError(
        context,
        description: e.localizedDescription,
      );
    }
  }

  // Purchase flow
  void startPurchase() {
    final appPurchase = sl<AppPurchase>();
    try {
      context.loaderOverlay.show();
      appPurchase.startPurchase(
        email: widget.email.validateEmail,
        planId: widget.plan!.id,
        onSuccess: () {
          context.loaderOverlay.hide();
          Future.delayed(const Duration(milliseconds: 400), openPassword);
        },
        onFailure: (error) {
          pinCodeController.clear();
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

  void openPassword() {
    context.pushRoute(CreateAccountPassword(
      email: widget.email.validateEmail,
      code: pinCodeController.text,
    ));
  }

  void resolveRoute() {
    switch (widget.authFlow) {
      case AuthFlow.signIn:
      // TODO: Handle this case.
      case AuthFlow.reset:
        context.router.pop();
      case AuthFlow.createAccount:
        startPurchase();
      case AuthFlow.verifyEmail:
        context.router.pop();
      case AuthFlow.proCodeActivation:
        context.pushRoute(ResellerCodeCheckout(
          isPro: false,
          email: widget.email,
          otp: pinCodeController.text,
        ));
      case AuthFlow.changeEmail:
      // TODO: Handle this case.
    }
  }
}
