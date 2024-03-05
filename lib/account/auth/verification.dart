// ignore_for_file: use_build_context_synchronously

import 'package:lantern/core/purchase/app_purchase.dart';

import '../../common/common.dart';

@RoutePage<void>(name: 'Verification')
class Verification extends StatefulWidget {
  final String email;
  final AuthFlow authFlow;
  final Plan? plan;

  const Verification(
      {super.key,
      required this.email,
      this.authFlow = AuthFlow.reset,
      this.plan});

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
      if (widget.authFlow == AuthFlow.createAccount) {
        await sessionModel.startRecoveryByEmail(widget.email);
      } else {
        await sessionModel.signUpEmailResendCode(widget.email);
      }
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
        context.router.popUntilRoot();
      case AuthFlow.verifyEmail:
        _verifyEmail(code);
        break;
      case AuthFlow.proCodeActivation:
        _verifyEmail(code);
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
      navigateToRoute();
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

  void navigateToRoute() {
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
    }
  }
}
