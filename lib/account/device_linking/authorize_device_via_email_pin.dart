// ignore_for_file: use_build_context_synchronously

import 'package:lantern/common/common.dart';
import 'package:styled_text/styled_text.dart';

@RoutePage<void>(name: 'AuthorizeDeviceEmailPin')
class AuthorizeDeviceViaEmailPin extends StatelessWidget {
  final String email;

  AuthorizeDeviceViaEmailPin({
    Key? key,
    required this.email,
  }) : super(key: key);

  final pinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Authorize Device via Email'.i18n,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(top: 32, bottom: 6),
            alignment: Alignment.center,
            child: CText(
              'Enter or paste linking code'.i18n.toUpperCase(),
              style: tsOverline,
            ),
          ),
          PinField(
            length: 6,
            controller: pinCodeController,
            onDone: (text) => onDone(text, context),
          ),
          LabeledDivider(
            padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
          ),
          emailDesc(),
          const Spacer(),
          Container(
            margin: const EdgeInsetsDirectional.only(bottom: 32),
            child: TextButton(
              onPressed: () => onResendCode(context),
              child: CText(
                'Re-send Email'.i18n.toUpperCase(),
                style: tsButtonPink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emailDesc() {
    return StyledText(
      text: 'recovery_email_sent'
          .i18n
          .replaceFirst('%s', '<highlight>$email</highlight>'),
      style: tsBody1,
      tags: {
        'highlight': StyledTextTag(
            style: TextStyle(color: blue4, fontWeight: FontWeight.bold)),
      },
    );
  }

  /// widget method

  Future<void> onDone(String code, BuildContext context) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.validateRecoveryCode(code);
      pinCodeController.clear();
      context.loaderOverlay.hide();
      CDialog.successDialog(
        context: context,
        title: "device_added".i18n,
        description: "device_added_msg".i18n.replaceAll('%s', email),
        successCallback: () {
          context.router.popUntilRoot();
        },
      );
    } catch (e) {
      pinCodeController.clear();
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }

  Future<void> onResendCode(BuildContext context) async {
    try {
      context.loaderOverlay.show();
      await sessionModel.authorizeViaEmail(email.validateEmail);
      context.loaderOverlay.hide();
      CDialog.successDialog(
          context: context,
          title: "recovery_code_sent".i18n,
          description: "recovery_email_sent".i18n.replaceAll('%s', email));
    } catch (e) {
      context.loaderOverlay.hide();
      CDialog.showError(context, description: e.localizedDescription);
    }
  }
}
