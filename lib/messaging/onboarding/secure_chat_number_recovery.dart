import '../messaging.dart';

class SecureNumberRecovery extends StatefulWidget {
  @override
  State<SecureNumberRecovery> createState() => _SecureNumberRecoveryState();
}

class _SecureNumberRecoveryState extends State<SecureNumberRecovery> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'recoveryInput');
  late final controller = CustomTextEditingController(
      formKey: _formKey, validator: (value) => null);
  var shouldSubmit = false;

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

  void handleButtonPress(MessagingModel model) async {
    controller.focusNode.unfocus();
    if (_formKey.currentState?.validate() == true) {
      try {
        context.loaderOverlay.show(widget: spinner);
        // await model.recoverAccount(controller.text); // TODO: once we have the recovery backend
        await model.markIsOnboarded();
        context.router.popUntilRoot();
        // TODO: show snackbar "You have successfully recovered your Secure Chat Number"
      } catch (e) {
        setState(() => controller.error = 'recovery_error'.i18n);
      } finally {
        context.loaderOverlay.hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();
    return BaseScreen(
        title: 'secure_chat_number_recovery'.i18n,
        body: PinnedButtonLayout(
            content: [
              Form(
                onChanged: () => setState(
                    () => shouldSubmit = controller.text.length >= 200),
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: 16.0),
                  child: CTextField(
                    controller: controller,
                    autovalidateMode: AutovalidateMode.disabled,
                    label: 'recovery_label'.i18n,
                    prefixIcon: null,
                    suffixIcon: null,
                    minLines: 5,
                    maxLines: null,
                  ),
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
                onPressed: () => handleButtonPress(model),
                disabled: !shouldSubmit)));
  }
}
