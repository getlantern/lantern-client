import 'package:lantern/messaging/messaging.dart';

class AddViaChatNumber extends StatefulWidget {
  @override
  _AddViaChatNumberState createState() => _AddViaChatNumberState();
}

class _AddViaChatNumberState extends State<AddViaChatNumber> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'chatNumberInput');
  late final controller = CustomTextEditingController(
      formKey: _formKey, validator: (value) => validateInput(value));
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
        var chatNumber = ChatNumber.create();
        if (controller.text.length >= 82) {
          // this is a full chat number, use it directly
          chatNumber.number = controller.text;
        } else {
          chatNumber = await model.findChatNumberByShortNumber(controller.text);
        }
        final contact =
            await model.addOrUpdateDirectContact(chatNumber: chatNumber);
        Navigator.pop(context, contact);
      } catch (e) {
        // TODO: handle error
      } finally {
        context.loaderOverlay.hide();
      }
    }
  }

  String? validateInput(String? value) {
    // input is invalid
    if (value == null || value.length < 12) {
      return 'chat_number_invalid'.i18n;
    }
    // input is valid
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
      title: 'add_contact'.i18n,
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Form(
                onChanged: () => setState(
                    () => shouldSubmit = _formKey.currentState!.validate()),
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 24.0, top: 60, end: 24.0),
                        child: Wrap(
                          children: [
                            CTextField(
                              controller: controller,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              label: 'chat_number'.i18n,
                              prefixIcon:
                                  const CAssetImage(path: ImagePaths.people),
                              hintText: 'chat_number_type'.i18n,
                              keyboardType: TextInputType.number,
                              maxLines: null,
                            ),
                          ],
                        ),
                      )
                    ]),
              ),
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(bottom: 32),
              child: Button(
                width: 200,
                text: 'start_chat'.i18n,
                onPressed: () => handleButtonPress(model),
                disabled: !shouldSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
