import 'package:lantern/messaging/conversation/replies/reply_mime.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet_description.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet_header.dart';
import 'package:lantern/messaging/conversation/replies/reply_snippet_text.dart';
import 'package:lantern/messaging/messaging.dart';

class ReplyPreview extends StatelessWidget {
  const ReplyPreview({
    Key? key,
    this.quotedMessage,
    required this.model,
    required this.onCloseListener,
    required this.contact,
  }) : super(key: key);

  final StoredMessage? quotedMessage;
  final MessagingModel model;
  final Function onCloseListener;
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final isNotNullOrDeleted =
        (quotedMessage != null && quotedMessage!.remotelyDeletedAt == 0);
    final isTextResponse = quotedMessage?.attachments.isEmpty ?? false;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(color: snippetBgColor),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReplySnippetHeader(message: quotedMessage!, contact: contact),
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                  ),
                  if (isNotNullOrDeleted && isTextResponse)
                    ReplySnippetText(text: quotedMessage!.text),
                  if (isNotNullOrDeleted && !isTextResponse)
                    ReplySnippetDescription(
                      descriptiveText: quotedMessage
                              ?.attachments[0]!.attachment.mimeType
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
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: ReplyMime(storedMessage: quotedMessage!, model: model),
              ),
            ),
          Container(
            width: 20,
            padding: const EdgeInsets.all(2.0),
            child: GestureDetector(
              key: const ValueKey('close_reply'),
              onTap: () => onCloseListener(),
              child: const CAssetImage(path: ImagePaths.cancel),
            ),
          ),
        ],
      ),
    );
  }
}
