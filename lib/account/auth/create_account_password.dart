import 'package:flutter/gestures.dart';

import '../../common/common.dart';

@RoutePage<void>(name: 'CreateAccountPassword')
class CreateAccountPassword extends StatefulWidget {
  final String email;

  const CreateAccountPassword({
    super.key,
    required this.email,
  });

  @override
  State<CreateAccountPassword> createState() => _CreateAccountPasswordState();
}

class _CreateAccountPasswordState extends State<CreateAccountPassword> {
  bool obscureText = false;
  final _passwordFormKey = GlobalKey<FormState>();
  late final _passwordController = CustomTextEditingController(
    formKey: _passwordFormKey,
  );

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'create_password'.i18n,
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
            _buildEmail(),
            const SizedBox(height: 24),
            CPasswordTextFiled(
                label: "create_password".i18n,
                passwordFormKey: _passwordFormKey,
                passwordCustomTextEditingController: _passwordController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Button(
                // disabled: _emailController.text.isEmpty ||
                //     _emailFormKey?.currentState?.validate() == false,
                text: 'continue'.i18n,
                onPressed: onContinueTap,
              ),
            ),
            const SizedBox(height: 24),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'by_creating_an_account'.i18n,
                    style: tsFloatingLabel,
                  ),
                  const TextSpan(
                    text: ' ',
                  ),
                  TextSpan(
                    text: 'terms_of_service'.i18n,
                    style: tsFloatingLabel!.copiedWith(
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = openTermsOfService,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmail() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: grey1,
        border: Border.all(
          width: 1,
          color: grey3,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SvgPicture.asset(
            ImagePaths.email,
          ),
          const SizedBox(width: 8),
          CText(widget.email,
              textAlign: TextAlign.center,
              style: tsBody1!.copiedWith(
                leadingDistribution: TextLeadingDistribution.even,
              ))
        ],
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

  ///Widget methods

  Future<void> onContinueTap() async {
    //Close keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      context.loaderOverlay.show();
      await sessionModel.signUp(widget.email, _passwordController.text);
      context.loaderOverlay.hide();
      openConfirmEmail();
    } catch (e) {
      context.loaderOverlay.hide();
    }
  }

  void openConfirmEmail() {
    FocusScope.of(context).unfocus();
    context.pushRoute(Verification(
        email: 'jigar@gmail.com', authFlow: AuthFlow.createAccount));
  }

  void openTermsOfService() {
    FocusScope.of(context).unfocus();
    context.pushRoute(AppWebview(url: termsOfService));
  }
}
