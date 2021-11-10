import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/messaging.dart';

class ContactNameDialog extends StatelessWidget {
  final BuildContext context;
  final GlobalKey formKey;
  final CustomTextEditingController controller;
  final MessagingModel model;
  final Contact contact;

  const ContactNameDialog({
    Key? key,
    required this.context,
    required this.formKey,
    required this.controller,
    required this.model,
    required this.contact,
  }) : super(key: key);

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
          children: [
            CText(
              'name_your_contact'.i18n,
              style: tsSubtitle1,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: 16,
                  bottom: 24,
                ),
                child: Form(
                    key: key,
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
                                  autovalidateMode: AutovalidateMode.disabled,
                                  label: 'display_name'.i18n,
                                  prefixIcon:
                                      const CAssetImage(path: ImagePaths.user),
                                  hintText: 'letter_and_numbers_only'.i18n,
                                  keyboardType: TextInputType.text,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          )
                        ])),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                focusColor: grey3,
                onTap: () async {
                  await model.addOrUpdateDirectContact(
                      unsafeId: contact.contactId.id,
                      displayName: controller.text);
                  await context.router.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: CText(
                    'DONE',
                    style: tsButtonPink,
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
