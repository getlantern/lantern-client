import 'package:lantern/account/auth/sign_in.dart';

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
      title: widget.authFlow.isCreateAccount
          ? 'confirm_email'
          : 'reset_password'.i18n,
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
            _buildHeader(),
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
            AppTextButton(
              text: 'change_email'.i18n,
              onPressed: () {
                context.popRoute();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SvgPicture.asset(
          ImagePaths.lantern_logo,
          height: 42,
        ),
        const SizedBox(width: 15),
        SvgPicture.asset(
          ImagePaths.free_logo,
          height: 25,
        ),
      ],
    );
  }

  /// widget methods
  void resendConfirmationCode() {}

  void onDone(String code) {
    switch (widget.authFlow) {
      case AuthFlow.createAccount:
        context.router.popUntilRoot();
        break;
      case AuthFlow.reset:
        openResetPassword();
        break;
      case AuthFlow.signIn:
        context.router.popUntilRoot();
        break;
    }
  }

  void openResetPassword() {
    context.pushRoute(const ResetPassword());
  }
}
