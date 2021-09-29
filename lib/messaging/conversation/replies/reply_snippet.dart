import 'package:collection/collection.dart';
import 'package:lantern/messaging/conversation/replies/reply_mime.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet_description.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet_header.dart';
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
              borderRadius:
                  const BorderRadius.all(Radius.circular(borderRadius)),
              boxShadow: [
                BoxShadow(
                  color: snippetShadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
              color: white),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 8, end: 8, bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReplySnippetHeader(
                          message: message, contact: contact, showIcon: true),
                      if (isNotNullOrDeleted && isTextResponse)
                        CText(quotedMessage!.value.text,
                            maxLines: 1, style: tsSubtitle1),
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
