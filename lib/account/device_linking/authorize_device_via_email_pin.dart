import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/common.dart';
import 'package:styled_text/styled_text.dart';

@RoutePage<void>(name: 'AuthorizeDeviceEmailPin')
class AuthorizeDeviceViaEmailPin extends StatelessWidget {
  AuthorizeDeviceViaEmailPin({Key? key}) : super(key: key);

  final pinCodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Widget emailSentMessage(String emailAddress) {
      return StyledText(
        text: 'recovery_email_sent'
            .i18n
            .replaceFirst('%s', '<highlight>$emailAddress</highlight>'),
        style: tsBody1,
        tags: {
          'highlight': StyledTextTag(
              style: TextStyle(color: blue4, fontWeight: FontWeight.bold)),
        },
      );
    }

    return sessionModel.emailAddress(
        (BuildContext context, String emailAddress, Widget? child) {
      return BaseScreen(
        title: 'Authorize Device via Email'.i18n,
        body: Form(
          key: formKey,
          child: Column(
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
                onDone: (code) {
                  context.loaderOverlay.show(widget: spinner);
                  sessionModel.validateRecoveryCode(code).then((value) {
                    pinCodeController.clear();
                    context.loaderOverlay.hide();
                  }).onError((error, stackTrace) {
                    pinCodeController.clear();
                    context.loaderOverlay.hide();
                  });
                },
              ),
              LabeledDivider(
                padding: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
              ),
              emailSentMessage(emailAddress),
              const Spacer(),
              Container(
                margin: const EdgeInsetsDirectional.only(bottom: 32),
                child: TextButton(
                  onPressed: () {
                    context.loaderOverlay.show(widget: spinner);
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
                                child: CText(
                                  'Okay'.i18n,
                                  style: tsButtonPink,
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
                  child: CText(
                    'Re-send Email'.i18n.toUpperCase(),
                    style: tsButtonPink,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
