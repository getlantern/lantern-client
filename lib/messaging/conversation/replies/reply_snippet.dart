import 'package:collection/collection.dart';

import 'package:lantern/messaging/conversation/replies/reply_mime.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet_description.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet_header.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet_text.dart';
import 'package:lantern/messaging/messaging.dart';

class ReplySnippet extends StatelessWidget {
  final bool outbound;
  final StoredMessage message;
  final Contact contact;

  const ReplySnippet(
    this.outbound,
    this.message,
    this.contact,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();
    return model.contactMessages(contact, builder: (context,
        Iterable<PathAndValue<StoredMessage>> messageRecords, Widget? child) {
      final quotedMessage = messageRecords
          .firstWhereOrNull((element) => element.value.id == message.replyToId);
      final isNotNullOrDeleted =
          (quotedMessage != null && quotedMessage.value.remotelyDeletedAt == 0);
      final isTextResponse = quotedMessage?.value.attachments.isEmpty ?? false;

      return Container(
          height: 56.0,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              boxShadow: [
                BoxShadow(
                  color: snippetShadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
              color: snippetBgColor),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 3.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReplySnippetHeader(message: message, contact: contact),
                      if (isNotNullOrDeleted && isTextResponse)
                        ReplySnippetText(text: quotedMessage!.value.text),
                      if (isNotNullOrDeleted && !isTextResponse)
                        ReplySnippetDescription(
                          descriptiveText: quotedMessage
                                  ?.value.attachments[0]!.attachment.mimeType
                                  .split('/')[0] ??
                              'error_fetching_message_preview'.i18n,
                        ),
                      if (!isNotNullOrDeleted)
                        ReplySnippetDescription(
                          descriptiveText: 'message_was_deleted'.i18n,
                        )
                    ],
                  ),
                ),
              ),
              if (isNotNullOrDeleted && !isTextResponse)
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8))),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: ReplyMime(
                        storedMessage: quotedMessage!.value, model: model),
                  ),
                )
            ],
          ));
    });
  }
}
