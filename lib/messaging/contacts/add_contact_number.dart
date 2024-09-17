import 'package:lantern/messaging/messaging.dart';

@RoutePage(name: 'AddViaChatNumber')
class AddViaChatNumber extends StatefulWidget {
  @override
  _AddViaChatNumberState createState() => _AddViaChatNumberState();
}

class _AddViaChatNumberState extends State<AddViaChatNumber> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'chatNumberInput');
  late final controller = CustomTextEditingController(
    formKey: _formKey,
    validator: (value) => null,
  );
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

  void handleButtonPress(MessagingModel model, Contact me) async {
    controller.focusNode.unfocus();
    if (_formKey.currentState?.validate() == true) {
      var chatNumber = ChatNumber.create();
      if (controller.text.length >= 82) {
        // this is a full chat number, use it directly
        chatNumber.number = controller.text.numbersOnly;
      } else {
        try {
          context.loaderOverlay.show(widget: spinner);
          chatNumber = await model
              .findChatNumberByShortNumber(controller.text.numbersOnly);

          if (chatNumber.number == me.chatNumber.number) {
            setState(() => controller.error = 'self_adding'.i18n);
            return;
          }
        } catch (e) {
          setState(() => controller.error = 'chat_number_not_found'.i18n);
          return;
        } finally {
          context.loaderOverlay.hide();
        }
      }
      try {
        final contact =
            await model.addOrUpdateDirectContact(chatNumber: chatNumber);
        await context.router.replace(
          Conversation(
            contactId: contact.contactId,
            showContactEditingDialog: true,
          ),
        );
      } catch (e) {
        setState(() => controller.error = 'unable_to_add_contact'.i18n);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'add_contact'.i18n,
      body: PinnedButtonLayout(
        content: [
          Form(
            onChanged: () => setState(
              () => shouldSubmit = controller.text.numbersOnly.length >= 12,
            ),
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.all(24.0),
                  child: Wrap(
                    children: [
                      CTextField(
                        controller: controller,
                        autovalidateMode: AutovalidateMode.disabled,
                        label: 'chat_number'.i18n,
                        prefixIcon:
                            const CAssetImage(path: ImagePaths.chatNumber),
                        hintText: 'chat_number_type'.i18n,
                        keyboardType: TextInputType.phone,
                        maxLines: null,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final original = newValue.text;
                            final formatted = original.formattedChatNumber;
                            var selection = newValue.selection;
                            if (formatted != original) {
                              final offset = formatted.characters.length;
                              selection = selection.copyWith(
                                baseOffset: offset,
                                extentOffset: offset,
                              );
                            }
                            return newValue.copyWith(
                              text: formatted,
                              selection: selection,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
        button: messagingModel.me(
          (context, me, child) => Button(
            width: 200,
            text: 'start_chat'.i18n,
            onPressed: () => handleButtonPress(messagingModel, me),
            disabled: !shouldSubmit,
          ),
        ),
      ),
    );
  }
}
