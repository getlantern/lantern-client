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
      if (controller.text.withoutWhitespace.length == 52) {
        try {
          context.loaderOverlay.show(widget: spinner);
          await model.recover(controller.text.withoutWhitespace);
          await model.markIsOnboarded();
          await model.markCopiedRecoveryKey();
          context.router.popUntilRoot();
          showSnackbar(
              context: context,
              content: 'recovery_success'.i18n,
              duration: longAnimationDuration);
        } catch (e) {
          setState(() => controller.error = 'recovery_error'.i18n);
        } finally {
          context.loaderOverlay.hide();
        }
      } else {
        setState(() => controller.error = 'recovery_input_error'.i18n);
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
                onChanged: () => setState(() => shouldSubmit =
                    controller.text.withoutWhitespace.length == 52),
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: 16.0),
                  child: CTextField(
                    controller: controller,
                    autovalidateMode: AutovalidateMode.disabled,
                    label: 'recovery_label'.i18n,
                    prefixIcon: null,
                    suffixIcon: null,
                    minLines: 2,
                    maxLines: null,
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final original = newValue.text;
                        final formatted = original.formattedRecoveryKey;
                        var selection = newValue.selection;
                        if (formatted != original) {
                          final offset = formatted.characters.length;
                          selection = selection.copyWith(
                              baseOffset: offset, extentOffset: offset);
                        }
                        return newValue.copyWith(
                            text: formatted, selection: selection);
                      }),
                    ],
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
                onPressed: () => handleButtonPress(model),
                disabled: !shouldSubmit)));
  }
}
