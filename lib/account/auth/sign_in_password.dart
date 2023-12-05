import 'package:flutter/gestures.dart';

import '../../common/common.dart';

@RoutePage<void>(name: 'SignInPassword')
class SignInPassword extends StatefulWidget {
  final String email;

  const SignInPassword({
    super.key,
    required this.email,
  });

  @override
  State<SignInPassword> createState() => _SignInPasswordState();
}

class _SignInPasswordState extends State<SignInPassword> {
  final _passwordFormKey = GlobalKey<FormState>();
  late final _passwordController = CustomTextEditingController(
    formKey: _passwordFormKey,
  );
  bool obscureText = false;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'enter_password'.i18n,
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
            CPasswordTextFiled(
                label: "enter_password".i18n,
                passwordFormKey: _passwordFormKey,
                passwordCustomTextEditingController: _passwordController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Button(text: 'continue'.i18n, onPressed: onContinueTap),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                text: 'forgot_your_password'.i18n,
                style:
                    tsBody1.copyWith(fontWeight: FontWeight.w400, color: grey5),
                children: [
                  TextSpan(
                    text: "click_here".i18n.toUpperCase(),
                    style: tsBody1.copyWith(
                        fontWeight: FontWeight.w500, color: pink5),
                    recognizer: TapGestureRecognizer()
                      ..onTap = openResetPasswordFlow,
                  ),
                ],
              ),
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

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFormKey.currentState?.dispose();
    super.dispose();
  }

  /// Widget methods
  void openResetPasswordFlow() {
    //Pop current route and push SignIn so back stack will handle
    context.router.popAndPush(SignIn(authFlow: AuthFlow.reset));
  }

  void onContinueTap() async {
    //Close keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      context.loaderOverlay.show();
      await sessionModel.login(widget.email, _passwordController.text);
      context.loaderOverlay.hide();
    } catch (e) {
      print(e);
      context.loaderOverlay.hide();
    }
  }
}
