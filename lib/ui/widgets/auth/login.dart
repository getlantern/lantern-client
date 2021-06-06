import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/routes.dart';
import 'package:lantern/ui/widgets/custom_text_field.dart';
import 'package:lantern/ui/widgets/auth/validators.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../button.dart';

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);

  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    return BaseScreen(
      title: 'Sign In'.i18n,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsetsDirectional.only(top: 32),
                child: CustomTextField(
                  controller: usernameController,
                  label: 'Username'.i18n,
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  validator: Validators.usernameValidator(),
                ),
              ),
              Container(
                margin: const EdgeInsetsDirectional.only(top: 32),
                child: CustomTextField(
                  controller: passwordController,
                  label: 'Password'.i18n,
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.black,
                  ),
                  suffixIcon: const Icon(
                    Icons.visibility,
                    color: Colors.black,
                  ),
                  validator: Validators.passwordValidator(),
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsetsDirectional.only(bottom: 32),
                child: Button(
                  width: 200,
                  text: 'Sign In'.i18n,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.loaderOverlay.show();
                      sessionModel
                          .login(usernameController.value.text,
                            passwordController.value.text)
                          .then((result) {
                        context.loaderOverlay.hide();
                        Navigator.pop(context);
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
      ),
    );
  }
}