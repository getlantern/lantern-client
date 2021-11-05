import '../messaging.dart';

class SecureNumberRecovery extends StatefulWidget {
  @override
  State<SecureNumberRecovery> createState() => _SecureNumberRecoveryState();
}

class _SecureNumberRecoveryState extends State<SecureNumberRecovery> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'recovery');
  late final controller = CustomTextEditingController(
      formKey: _formKey, validator: (value) => validateInput(value));

  @override
  void initState() {
    super.initState();
    controller.focusNode.requestFocus();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String? validateInput(String? value) {
    // input is invalid
    if (value == null || value.length < 82) {
      return 'recovery_helper_text'.i18n;
    }
    // input is valid
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();
    return BaseScreen(
        title: 'secure_chat_number_recovery'.i18n,
        body: PinnedButtonLayout(
            content: [
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 16.0),
                child: CTextField(
                  controller: controller,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  label: 'recovery_label'.i18n,
                  prefixIcon: null,
                  suffixIcon: null,
                  minLines: 5,
                  maxLines: null,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 8.0),
                child: CText('recovery_button'.i18n, style: tsBody1),
              ),
            ],
            button: Button(
              text: 'Submit'.i18n,
              width: 200.0,
              onPressed: () async {
                try {
                  context.loaderOverlay.show(widget: spinner);
                  // await model.recoverAccount();   // TODO: handle recovery
                } catch (e, s) {
                  showErrorDialog(context,
                      e: e,
                      s: s,
                      des:
                          'Something went wrong with recovering your account.');
                  await context.router.pop();
                } finally {
                  context.loaderOverlay.hide();
                  await model.markIsOnboarded();
                  context.router
                      .popUntilRoot(); //clear MessagesRouter and start again without onboarding
                }
              },
            )));
  }
}
