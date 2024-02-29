// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';

import '../../common/common.dart';

@RoutePage<void>(name: 'ChangeEmail')
class ChangeEmail extends StatefulWidget {
  final String email;

  const ChangeEmail({
    super.key,
    required this.email,
  });

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final _emailFormKey = GlobalKey<FormState>();
  late final _emailController = CustomTextEditingController(
    formKey: _emailFormKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );

  bool obscureText = false;
  final _passwordFormKey = GlobalKey<FormState>();
  late final _passwordController = CustomTextEditingController(
    formKey: _passwordFormKey,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: const AppBarProHeader(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 24),
        HeadingText(
          title: 'change_email'.i18n,
        ),
        const SizedBox(height: 24),
        Form(
          key: _emailFormKey,
          child: CTextField(
            controller: _emailController,
            label: "new_email".i18n,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: SvgPicture.asset(ImagePaths.email),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 20),
        CPasswordTextFiled(
          label: "password".i18n,
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
            disabled: isButtonDisabled(),
            text: 'change_email'.i18n,
            onPressed: onChangeEmail,
          ),
        ),
      ],
    );
  }

  ///Widget methods
  bool isButtonDisabled() {
    if (EmailValidator.validate(_emailController.text) &&
        _passwordController.text.length > 8) {
      return false;
    }

    return true;
  }

  Future<void> onChangeEmail() async {
    //Close keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    if (widget.email.validateEmail.toLowerCase() ==
        _emailController.text.validateEmail.toLowerCase()) {
      CDialog.showError(context,
          description: 'new_email_same_as_old_email'.i18n);
      return;
    }

    try {
      context.loaderOverlay.show();
      await sessionModel.changeEmail(
          widget.email, _emailController.text, _passwordController.text);
      context.loaderOverlay.hide();
      CDialog.successDialog(
        context: context,
        title: 'email_has_been_updated'.i18n,
        description: 'email_has_been_updated_message'.i18n,
        successCallback: () {
          //Once email changed, pop
          context.router.pop();
        },
      );
    } catch (e) {
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }
}
