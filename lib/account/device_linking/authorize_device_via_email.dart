import 'package:email_validator/email_validator.dart';
import 'package:lantern/common/common.dart';


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
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.loaderOverlay.show(widget: spinner);
                    sessionModel
                        .authorizeViaEmail(emailController.value.text)
                        .then((result) async {
                      context.loaderOverlay.hide();
                      await context.pushRoute(AuthorizeDeviceEmailPin());
                    }).onError((error, stackTrace) {
                      context.loaderOverlay.hide();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
