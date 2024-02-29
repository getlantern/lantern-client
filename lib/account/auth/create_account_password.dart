import 'package:flutter/gestures.dart';
import 'package:lantern/common/ui/custom/logo_with_text.dart';
import 'package:lantern/common/ui/password_criteria.dart';

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
        title:const AppBarProHeader(),
        body: _buildBody(context),);
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              HeadingText(title: 'create_password'.i18n,),
              const SizedBox(height: 24),
              _buildEmail(),
              const SizedBox(height: 24),
              CPasswordTextFiled(
                label: "create_password".i18n,
                passwordFormKey: _passwordFormKey,
                passwordCustomTextEditingController: _passwordController,
                onChanged: (vaule) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 14),
              PasswordCriteriaWidget(
                textEditingController: _passwordController,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Button(
                  disabled: (!_passwordController.text.isPasswordValid()),
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
              ),
              const SizedBox(height: 20),
            ],
          ),
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

  ///Widget methods

  Future<void> onContinueTap() async {
    //Close keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      context.loaderOverlay.show();
      await sessionModel.signUp(widget.email, _passwordController.text);
      context.loaderOverlay.hide();
      openConfirmEmail();
    } catch (e, s) {
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  void openConfirmEmail() {
    FocusScope.of(context).unfocus();
    context.pushRoute(
        Verification(email: widget.email, authFlow: AuthFlow.createAccount));
  }

  void openTermsOfService() {
    FocusScope.of(context).unfocus();
    context.pushRoute(AppWebview(url: termsOfService));
  }
}
