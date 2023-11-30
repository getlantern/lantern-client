import 'package:email_validator/email_validator.dart';

import '../../common/common.dart';

@RoutePage<void>(name: 'SignIn')
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
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.authFlow.isReset ? 'reset_password'.i18n : 'sign_in'.i18n,
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
            Form(
              key: _emailFormKey,
              child: CTextField(
                controller: _emailController,
                label: widget.authFlow.isReset
                    ? "lantern_pro_email".i18n
                    : "enter_email".i18n,
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
                text: widget.authFlow.isReset ? "next".i18n : 'continue'.i18n,
                onPressed: widget.authFlow.isReset
                    ? openVerification
                    : openCreatePassword,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.authFlow.isReset)
              AppTextButton(
                text: 'return_to_sign_in'.i18n.toUpperCase(),
                onPressed: returnToSignIn,
              )
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

  @override
  void dispose() {
    _emailController.dispose();
    _emailFormKey.currentState?.dispose();
    super.dispose();
  }

  ///Widget methods
  void openCreatePassword() {
    context.pushRoute(const SignInPassword());
  }

  void openVerification() {
    context.pushRoute(Verification(email: _emailController.text));
  }

  void returnToSignIn() {
    context.popRoute();
  }
}
