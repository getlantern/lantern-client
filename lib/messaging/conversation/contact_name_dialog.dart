import 'package:lantern/messaging/messaging.dart';

class ContactNameDialog extends StatefulWidget {
  final BuildContext context;
  final Contact contact;

  const ContactNameDialog({
    Key? key,
    required this.context,
    required this.contact,
  }) : super(key: key);

  @override
  State<ContactNameDialog> createState() => _ContactNameDialogState();
}

class _ContactNameDialogState extends State<ContactNameDialog> {
  final _key = GlobalKey<FormState>(debugLabel: 'contactNameInput');
  late final controller =
      CustomTextEditingController(formKey: _key, validator: (value) => null);
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

  void submit(BuildContext context, String value) async {
    if (shouldSubmit) {
      await messagingModel.addOrUpdateDirectContact(
        unsafeId: widget.contact.contactId.id,
        displayName: value,
      );
      await context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsetsDirectional.all(24.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CText(
              'name_your_contact'.i18n,
              style: tsSubtitle1,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Form(
                key: _key,
                onChanged: () =>
                    setState(() => shouldSubmit = controller.text.isNotEmpty),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 0,
                        top: 16.0,
                        end: 0,
                        bottom: 16.0,
                      ),
                      child: Wrap(
                        children: [
                          CTextField(
                            controller: controller,
                            autovalidateMode: AutovalidateMode.disabled,
                            label: 'display_name'.i18n,
                            prefixIcon:
                                const CAssetImage(path: ImagePaths.user),
                            helperText: 'letter_and_numbers_only'.i18n,
                            keyboardType: TextInputType.text,
                            maxLines: null,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (value) => submit(context, value),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                focusColor: grey3,
                onTap: () => submit(context, controller.text),
                child: Container(
                  padding: const EdgeInsetsDirectional.all(8),
                  child: CText(
                    'Done'.i18n.toUpperCase(),
                    style: shouldSubmit ? tsButtonPink : tsButtonGrey,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
