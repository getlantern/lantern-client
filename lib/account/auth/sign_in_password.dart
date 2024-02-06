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
    validator: (value) {
      if (value!.isEmpty) {
        return 'password_cannot_be_empty'.i18n;
      }
      if (value.length < 8) {
        return 'password_must_be_at_least_8_characters'.i18n;
      }
      return null;
    },
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
            const LogoWithText(),
            const SizedBox(height: 24),
            CPasswordTextFiled(
              label: "enter_password".i18n,
              passwordFormKey: _passwordFormKey,
              passwordCustomTextEditingController: _passwordController,
              onChanged: (vaule) {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Button(
                disabled: _passwordController.text.length < 8,
                text: 'continue'.i18n,
                onPressed: onContinueTap,
              ),
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
      context.router.popUntilRoot();
    } catch (error) {
      mainLogger.e("Error while sign in ", error: error);
      context.loaderOverlay.hide();

      /// User has connected more then 3 device
      /// Show screen to user to remove device
      if ((error as PlatformException).message!.contains("too-many-devices")) {
        context.pushRoute(DeviceLimit()).then((value) {
          if (value != null && value as bool) {
            mainLogger.i("Device has been removed");
            onContinueTap();
          }
        });
        return;
      }
      CDialog.showError(context, description: error.localizedDescription);
    }
  }
}
