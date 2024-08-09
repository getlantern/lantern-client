// ignore_for_file: use_build_context_synchronously

import 'package:lantern/core/purchase/app_purchase.dart';
import 'package:lantern/plans/utils.dart';
import 'package:lantern/vpn/vpn.dart';

import '../../common/common.dart';
import 'change_email.dart';

@RoutePage<void>(name: 'Verification')
class Verification extends StatefulWidget {
  final String email;
  final AuthFlow authFlow;
  final Plan? plan;
  final ChangeEmailPageArgs? changeEmailArgs;
  final String? tempPassword;
  final String? purchaseToken;

  const Verification({
    super.key,
    required this.email,
    this.authFlow = AuthFlow.reset,
    this.changeEmailArgs,
    this.plan,
    this.tempPassword,
    this.purchaseToken,
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
      onBackButtonPressed: onBackPressed,
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
                  !widget.authFlow.isCreateAccount &&
                  !widget.authFlow.isProCodeActivation)
                AppTextButton(
                  text: 'change_email'.i18n.toUpperCase(),
                  onPressed: () {
                    context.maybePop();
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
      case AuthFlow.updateAccount:
        resendResetEmailVerificationCode();
      case AuthFlow.restoreAccount:
        resendRestoreEmailVerificationCode();
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
      showSnackbar(context: context, content: 'email_resend_message'.i18n);
    } catch (e, s) {
      mainLogger.e('Error while resending code', error: e, stackTrace: s);
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  Future<void> resendRestoreEmailVerificationCode() async {
    try {
      context.loaderOverlay.show();
      await sessionModel.authorizeViaEmail(widget.email);
      context.loaderOverlay.hide();
      showSnackbar(context: context, content: 'email_resend_message'.i18n);
    } catch (e, s) {
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
        _verifyEmail(code);

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
      case AuthFlow.updateAccount:
        _verifyEmail(code);
      case AuthFlow.restoreAccount:
        _verifyRestorePurchaseEmail(code);
    }
  }

  void openResetPassword(String code) {
    context.pushRoute(ResetPassword(
        email: widget.email, code: code, authFlow: widget.authFlow));
  }

  void _verifyEmail(String code) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.validateRecoveryCode(widget.email, code);
      context.loaderOverlay.hide();
      resolveRoute(code);
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

  void _verifyRestorePurchaseEmail(String code) {
    try {
      context.loaderOverlay.show();
      sessionModel.validateDeviceRecoveryCode(code, widget.email);
      context.loaderOverlay.show();
      resolveRoute(code);
    } catch (e) {
      showError(context, description: e.localizedDescription);
    }
  }

  // Purchase flow
  void startPurchase() {
    switch (Platform.operatingSystem) {
      case "ios":
        _proceedToCheckoutIOS();
        break;
      default:
        _proceedToCheckout();
    }
  }

  void _proceedToCheckoutIOS() {
    assert(widget.plan != null, 'Plan object is null');
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
      mainLogger.e("Error while purchase flow", error: e);
      context.loaderOverlay.hide();
      CDialog.showError(
        context,
        error: e,
        description: e.toString(),
      );
    }
  }

  void _proceedToCheckout() {
    context.pushRoute(Checkout(
      plan: widget.plan!,
      isPro: false,
      authFlow: widget.authFlow,
      email: widget.email,
      verificationPin: pinCodeController.text,
    ));
  }

  void openPassword() {
    context.pushRoute(CreateAccountPassword(
      email: widget.email.validateEmail,
      code: pinCodeController.text,
    ));
  }

  Future<void> resolveRoute(String code) async {
    switch (widget.authFlow) {
      case AuthFlow.signIn:
      // TODO: Handle this case.
      case AuthFlow.reset:
        openResetPassword(code);
      case AuthFlow.createAccount:

        ///Check if user is from app store or play store build
        if (isAppStoreEnabled() || (await isPlayStoreEnabled())) {
          openPassword();
          return;
        }
        startPurchase();
      case AuthFlow.verifyEmail:
        context.router.maybePop();
      case AuthFlow.proCodeActivation:
        context.pushRoute(ResellerCodeCheckout(
          isPro: false,
          email: widget.email,
          otp: pinCodeController.text,
        ));
      case AuthFlow.changeEmail:
      // TODO: Handle this case.
      case AuthFlow.updateAccount:
        openResetPassword(code);
      case AuthFlow.restoreAccount:
        _restoreAccount(code);
    }
  }

  Future<void> onBackPressed() async {
    if (widget.authFlow == AuthFlow.createAccount ||
        widget.authFlow == AuthFlow.updateAccount ||
        widget.authFlow == AuthFlow.proCodeActivation) {
      assert(widget.tempPassword != null, 'Temp password is null');
      // if user press back button while creating account
      // we need to delete that temp account
      await _deleteAccount(widget.tempPassword!);
      context.maybePop();
      return;
    }
    context.maybePop();
  }

  Future<void> _deleteAccount(String password) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.deleteAccount(password);
      context.loaderOverlay.hide();
    } catch (e) {
      context.loaderOverlay.hide();
      mainLogger.e("Error while deleting account", error: e);
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  Future<void> _restoreAccount(String code) async {
    try {
      assert(widget.purchaseToken != null, 'Purchase token is null');
      context.loaderOverlay.show();
      await sessionModel.restoreAccount(widget.email, code, widget.purchaseToken!!);
      context.loaderOverlay.hide();
      CDialog.successDialog(
        context: context,
        title: "purchase_restored".i18n,
        description: "purchase_restored_message".i18n,
        successCallback: () {
          context.router.popUntilRoot();
        },
      );
    } catch (e) {
      context.loaderOverlay.hide();
      mainLogger.e("Error while restoring account", error: e);
      CDialog.showError(context, description: e.localizedDescription);
    }
  }
}
