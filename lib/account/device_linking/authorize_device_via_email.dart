// ignore_for_file: use_build_context_synchronously

import 'package:email_validator/email_validator.dart';
import 'package:lantern/common/common.dart';

@RoutePage<void>(name: 'AuthorizeDeviceEmail')
class AuthorizeDeviceViaEmail extends StatelessWidget {
  AuthorizeDeviceViaEmail({Key? key}) : super(key: key);

  final formKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    formKey: formKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'Please enter a valid email address'.i18n,
  );

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Authorize Device via Email'.i18n,
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsetsDirectional.only(top: 32),
              child: CTextField(
                controller: emailController,
                autovalidateMode: AutovalidateMode.disabled,
                //TODO: this throws an error when we set it to AutovalidateMode.onUserInteraction
                label: 'Email'.i18n,
                helperText: 'auth_email_helper_text'.i18n,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const CAssetImage(path: ImagePaths.email),
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsetsDirectional.only(bottom: 32),
              child: Button(
                text: 'Submit'.i18n,
                onPressed: () => onSubmit(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSubmit(BuildContext context) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }
      context.loaderOverlay.show(widget: spinner);
      await sessionModel.authorizeViaEmail(emailController.value.text);
      context.loaderOverlay.hide();
      context.pushRoute(AuthorizeDeviceEmailPin(email: emailController.value.text));
    } catch (e) {
      context.loaderOverlay.hide();
    }
  }
}
