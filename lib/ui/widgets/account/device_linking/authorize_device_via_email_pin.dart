import 'package:flutter/cupertino.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_pin_field.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:styled_text/styled_text.dart';

class AuthorizeDeviceViaEmailPin extends StatelessWidget {
  AuthorizeDeviceViaEmailPin({Key? key}) : super(key: key);

  final pinCodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var sessionModel = context.watch<SessionModel>();

    Widget emailSentMessage(String emailAddress) {
      return StyledText(
        text: 'recovery_email_sent'
            .i18n
            .replaceFirst('%s', '<highlight>$emailAddress</highlight>'),
        styles: {
          'highlight':
              TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        },
      );
    }

    return sessionModel.subscribedSingleValueBuilder('emailAddress',
        builder: (BuildContext context, String emailAddress, Widget? child) {
      return BaseScreen(
        title: 'Authorize Device via Email'.i18n,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsetsDirectional.only(top: 32, bottom: 6),
                  alignment: Alignment.center,
                  child: Text(
                      'Enter or paste device linking PIN'.i18n.toUpperCase()),
                ),
                CustomPinField(
                  length: 6,
                  controller: pinCodeController,
                  onDone: (code) {
                    context.loaderOverlay.show();
                    sessionModel.validateRecoveryCode(code).then((value) {
                      pinCodeController.text = '';
                      context.loaderOverlay.hide();
                    }).onError((error, stackTrace) {
                      pinCodeController.text = '';
                      context.loaderOverlay.hide();
                    });
                  },
                ),
                CustomDivider(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                emailSentMessage(emailAddress),
                const Spacer(),
                Container(
                  margin: const EdgeInsetsDirectional.only(bottom: 32),
                  child: TextButton(
                    onPressed: () {
                      context.loaderOverlay.show();
                      sessionModel.resendRecoveryCode().then((value) {
                        context.loaderOverlay.hide();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: emailSentMessage(emailAddress),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Okay'.i18n,
                                    style: TextStyle(color: primaryPink),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }).onError((error, stackTrace) {
                        context.loaderOverlay.hide();
                      });
                    },
                    child: Text(
                      'Re-send Email'.i18n.toUpperCase(),
                      style: TextStyle(color: primaryPink),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
