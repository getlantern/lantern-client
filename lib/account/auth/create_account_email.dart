import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';

import '../../common/common.dart';

@RoutePage<void>(name: 'CreateAccountEmail')
class CreateAccountEmail extends StatefulWidget {
  const CreateAccountEmail({super.key});

  @override
  State<CreateAccountEmail> createState() => _CreateAccountEmailState();
}

class _CreateAccountEmailState extends State<CreateAccountEmail> {
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
      title: 'create_account'.i18n,
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
                label: "enter_email".i18n,
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
                // disabled: _emailController.text.isEmpty ||
                //     _emailFormKey?.currentState?.validate() == false,
                text: 'continue'.i18n,
                onPressed: openPassword,
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                text: 'already_have_an_account'.i18n,
                style:
                    tsBody1.copyWith(fontWeight: FontWeight.w400, color: grey5),
                children: [
                  TextSpan(
                    text: "sign_in".i18n.toUpperCase(),
                    style: tsBody1.copyWith(
                        fontWeight: FontWeight.w500, color: pink5),
                    recognizer: TapGestureRecognizer()..onTap = openSignInFlow,
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
    _emailController.dispose();
    _emailFormKey.currentState?.dispose();
    super.dispose();
  }

  ///Widget methods

  void openSignInFlow() {
    context.pushRoute(SignIn());
  }

  void openPassword() {
    context.pushRoute(const CreateAccountPassword());
  }

  void emailExistsDialog() {
    showEmailExistsDialog(
      context: context,
      recoverTap: () {},
    );
  }
}
