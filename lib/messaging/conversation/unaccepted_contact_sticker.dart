import 'package:lantern/messaging/messaging.dart';

class UnacceptedContactSticker extends StatelessWidget {
  const UnacceptedContactSticker({
    Key? key,
    required this.messageCount,
    required this.contact,
  }) : super(key: key);

  final int messageCount;
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: grey1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 16.0,
              end: 16.0,
              top: 24.0,
            ),
            child: CText(
              'banner_unaccepted'
                  .i18n
                  .fill([contact.chatNumber.shortNumber.formattedChatNumber]),
              style: tsBody1.copiedWith(color: grey5),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () async => showInfoDialog(
                  context,
                  title: '${'delete_contact'.i18n}?',
                  des: 'delete_info_description'.i18n,
                  assetPath: ImagePaths.delete,
                  cancelButtonText: 'cancel'.i18n,
                  confirmButtonText: 'delete_contact'.i18n,
                  confirmButtonAction: () async {
                    context.loaderOverlay.show(widget: spinner);
                    try {
                      await messagingModel
                          .deleteDirectContact(contact.contactId.id);
                    } catch (e, s) {
                      showErrorDialog(
                        context,
                        e: e,
                        s: s,
                        des: 'error_delete_contact'.i18n,
                      );
                    } finally {
                      showSnackbar(
                        context: context,
                        content: 'contact_was_deleted'
                            .i18n
                            .fill([contact.displayNameOrFallback]),
                      );
                      context.loaderOverlay.hide();
                      context.router.popUntilRoot();
                    }
                  },
                ),
                child: CText(
                  'Delete'.i18n.toUpperCase(),
                  style: tsButton,
                ),
              ),
              TextButton(
                onPressed: () async => showInfoDialog(
                  context,
                  assetPath: ImagePaths.block,
                  title: contact.blocked
                      ? '${'unblock'.i18n} ${contact.displayNameOrFallback}?'
                      : '${'block'.i18n} ${contact.displayNameOrFallback}?',
                  des: contact.blocked
                      ? 'unblock_info_description'
                          .i18n
                          .fill([contact.displayNameOrFallback])
                      : 'block_info_description'.i18n,
                  checkboxText: contact.blocked
                      ? 'unblock_info_checkbox'.i18n
                      : 'block_info_checkbox'.i18n,
                  confirmCheckboxAction: () async {
                    context.loaderOverlay.show(widget: spinner);
                    try {
                      await messagingModel
                          .deleteDirectContact(contact.contactId.id);
                    } catch (e, s) {
                      showErrorDialog(
                        context,
                        e: e,
                        s: s,
                        des: 'error_delete_contact'.i18n,
                      );
                    } finally {
                      showSnackbar(
                        context: context,
                        content: 'contact_was_deleted'
                            .i18n
                            .fill([contact.displayNameOrFallback]),
                      );
                      context.loaderOverlay.hide();
                      context.router.popUntilRoot();
                    }
                  },
                ),
                child: CText(
                  'Block'.i18n.toUpperCase(),
                  style: tsButton,
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final _contact =
                        await messagingModel.addOrUpdateDirectContact(
                      chatNumber: contact.chatNumber,
                    );
                    await context.router.popAndPush(
                      Conversation(
                        contactId: _contact.contactId,
                        showContactEditingDialog: true,
                      ),
                    );
                  } catch (e) {
                    showInfoDialog(
                      context,
                      des:
                          'Something went wrong while adding this contact'.i18n,
                      confirmButtonAction: () async =>
                          await context.router.pop(),
                    );
                  }
                },
                child: CText(
                  'Accept'.i18n.toUpperCase(),
                  style: tsButtonBlue,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
