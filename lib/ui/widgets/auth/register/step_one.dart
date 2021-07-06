import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/routes.dart';
import 'package:lantern/ui/widgets/custom_text_field.dart';
import 'package:lantern/ui/widgets/auth/validators.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../button.dart';

class StepOne extends StatelessWidget {
  StepOne({Key? key}) : super(key: key);

  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var authModel = context.watch<AuthModel>();

    return BaseScreen(
      title: 'Create Account'.i18n,
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
              const Spacer(),
              Container(
                margin: const EdgeInsetsDirectional.only(bottom: 32),
                child: Button(
                  width: 200,
                  text: 'Continue'.i18n,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.loaderOverlay.show();
                      authModel
                          .setUsername(usernameController.value.text);
                      context.loaderOverlay.hide();
                      Navigator.pushNamed(
                            context, routeAuthRegisterStepTwo);
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