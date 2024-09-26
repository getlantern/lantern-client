import 'package:lantern/features/messaging/messaging.dart';

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
                onPressed: () async => CDialog(
                  title: 'delete_contact'.i18n,
                  description: 'delete_info_description'.i18n,
                  iconPath: ImagePaths.delete,
                  agreeText: 'delete_contact'.i18n,
                  agreeAction: () async {
                    context.loaderOverlay.show(widget: spinner);
                    try {
                      await messagingModel
                          .deleteDirectContact(contact.contactId.id);
                    } catch (e, s) {
                      CDialog.showError(
                        context,
                        error: e,
                        stackTrace: s,
                        description: 'error_delete_contact'.i18n,
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
                      return false;
                    }
                  },
                ).show(context),
                child: CText(
                  'delete'.i18n.toUpperCase(),
                  style: tsButton,
                ),
              ),
              TextButton(
                onPressed: () async => CDialog(
                  iconPath: ImagePaths.block,
                  title: '${'block'.i18n} ${contact.displayNameOrFallback}?',
                  description: 'block_info_description'.i18n,
                  checkboxLabel: 'block_info_checkbox'.i18n,
                  agreeText: 'block'.i18n.toUpperCase(),
                  agreeAction: () async {
                    context.loaderOverlay.show(widget: spinner);
                    try {
                      await messagingModel
                          .blockDirectContact(contact.contactId.id);
                    } catch (e, s) {
                      CDialog.showError(
                        context,
                        error: e,
                        stackTrace: s,
                        description: 'error_delete_contact'.i18n,
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
                      return false;
                    }
                  },
                ).show(context),
                child: CText(
                  'block'.i18n.toUpperCase(),
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
                    CDialog.showError(
                      context,
                      description:
                          'Something went wrong while adding this contact'.i18n,
                    );
                  }
                },
                child: CText(
                  'accept'.i18n.toUpperCase(),
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
