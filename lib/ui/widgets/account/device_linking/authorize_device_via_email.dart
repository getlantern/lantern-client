import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_text_field.dart';

import '../../button.dart';

class AuthorizeDeviceViaEmail extends StatelessWidget {
  AuthorizeDeviceViaEmail({Key? key}) : super(key: key);

  void linkWithPin() {
    LanternNavigator.startScreen(LanternNavigator.SCREEN_LINK_PIN);
  }

  var emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Authorize Device via Email'.i18n,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsetsDirectional.only(top: 32),
              child: CustomTextField(
                controller: emailController,
                label: 'Email'.i18n,
                helperText:
                    'Enter the email associated with your Pro account'.i18n,
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.black,
                ),
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsetsDirectional.only(bottom: 32),
              child: Button(
                width: 200,
                text: 'Submit'.i18n,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
