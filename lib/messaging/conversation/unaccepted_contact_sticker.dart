import 'package:lantern/messaging/contacts/show_block_contact_dialog.dart';
import 'package:lantern/messaging/contacts/show_delete_contact_dialog.dart';
import 'package:lantern/messaging/messaging.dart';

import 'message_retention.dart';

class UnacceptedContactSticker extends StatelessWidget {
  const UnacceptedContactSticker({
    Key? key,
    required this.messageCount,
    required this.contact,
    required this.model,
  }) : super(key: key);

  final int messageCount;
  final Contact contact;
  final MessagingModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: calculateStickerHeight(context, messageCount),
      child: Column(
        children: [
          Container(
            color: grey1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 16.0,
                    end: 16.0,
                    top: 24.0,
                  ),
                  child: CText(
                      'banner_unaccepted'.i18n.fill(
                          [contact.chatNumber.shortNumber.formattedChatNumber]),
                      style: tsBody1.copiedWith(color: grey5)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async => showDeleteContactDialog(
                        context,
                        contact,
                        model,
                      ),
                      child: CText(
                        'Delete'.i18n.toUpperCase(),
                        style: tsButton,
                      ),
                    ),
                    TextButton(
                      onPressed: () async => showBlockContactDialog(
                        context,
                        contact,
                        model,
                      ),
                      child: CText(
                        'Block'.i18n.toUpperCase(),
                        style: tsButton,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          final _contact = await model.addOrUpdateDirectContact(
                              chatNumber: contact.chatNumber);
                          await context.router.popAndPush(Conversation(
                              contactId: _contact.contactId,
                              showContactEditingDialog: true));
                        } catch (e) {
                          showInfoDialog(context,
                              des:
                                  'Something went wrong while adding this contact'
                                      .i18n);
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
          ),
          MessageRetention(
            contact: contact,
          )
        ],
      ),
    );
  }
}
