import '../messaging.dart';

class Recovery extends StatefulWidget {
  @override
  State<Recovery> createState() => _RecoveryState();
}

class _RecoveryState extends State<Recovery> {
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
      // TODO: confirm recovery length
      return 'please enter a valid recovery key'.i18n;
    }
    // input is valid
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
      title: 'recovery'.i18n,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: CTextField(
              controller: controller,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              label: 'Enter your Recovery Key'.i18n,
              prefixIcon: null,
              suffixIcon: null,
              minLines: 5,
              maxLines: null,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: CText(
                'Enter your  Recovery Key to restore your Lantern Secure Chat Number.'
                    .i18n,
                style: tsBody1),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: Button(
              text: 'Submit'.i18n,
              width: 200.0,
              onPressed: () => {}, // TODO: handle recovery
            ),
          ),
        ],
      ),
    );
  }
}
