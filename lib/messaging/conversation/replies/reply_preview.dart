import 'package:lantern/messaging/conversation/replies/reply_snippet_header.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/messaging/conversation/mime_types.dart';
import 'package:lantern/vpn/vpn.dart';

class ReplyPreview extends StatelessWidget {
  final StoredMessage? quotedMessage;
  final MessagingModel model;
  final void Function() onCancel;
  final Contact contact;

  const ReplyPreview({
    Key? key,
    this.quotedMessage,
    required this.model,
    required this.onCancel,
    required this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNotNullOrDeleted =
        (quotedMessage != null && quotedMessage!.remotelyDeletedAt == 0);
    final isTextResponse = quotedMessage?.attachments.isEmpty ?? false;
    return Container(
      height: 68,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
              height: 56,
              margin: const EdgeInsetsDirectional.only(top: 12),
              padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
              decoration: BoxDecoration(color: grey2),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 16),
                      child: isTextResponse
                          ? CText(quotedMessage!.text,
                              maxLines: 1, style: tsSubtitle1.short)
                          : attachmentInfo(context),
                    ),
                  ),
                  IconButton(
                    iconSize: 24,
                    padding: EdgeInsetsDirectional.zero,
                    icon: const CAssetImage(path: ImagePaths.delete),
                    onPressed: onCancel,
                  )
                ],
              )),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child:
                ReplySnippetHeader(message: quotedMessage!, contact: contact),
          ),
        ],
      ),
    );
  }

  Widget attachmentInfo(BuildContext context) {
    final mimeType =
        mimeTypeOf(quotedMessage!.attachments[0]!.attachment.mimeType);
    var text = 'attachment'.i18n;
    Widget image = const CAssetImage(path: ImagePaths.insert_drive_file);
    switch (mimeType) {
      case MimeType.AUDIO:
        text = 'audio'.i18n;
        image = const CAssetImage(path: ImagePaths.volume_up);
    }

    return Row(
      children: [
        Expanded(
          child: CText(text, maxLines: 1, style: tsSubtitle1.italic),
        ),
        image,
      ],
    );
  }
}

// Row(
// mainAxisSize: MainAxisSize.max,
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Flexible(
// child: Padding(
// padding: const EdgeInsets.all(4.0),
// child: Column(
// mainAxisAlignment: MainAxisAlignment.start,
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// const Padding(
// padding: EdgeInsets.all(2.0),
// ),
// if (isNotNullOrDeleted && isTextResponse)
// ReplySnippetText(text: quotedMessage!.text),
// if (isNotNullOrDeleted && !isTextResponse)
// ReplySnippetDescription(
// descriptiveText: quotedMessage
//     ?.attachments[0]!.attachment.mimeType
//     .split('/')[0] ??
// 'error_fetching_message_preview'.i18n,
// ),
// if (!isNotNullOrDeleted)
// ReplySnippetDescription(
// descriptiveText: 'message_was_deleted'.i18n,
// )
// ],
// ),
// ),
// ),
// if (isNotNullOrDeleted && !isTextResponse)
// Container(
// width: 56,
// height: 56,
// child: FittedBox(
// fit: BoxFit.cover,
// clipBehavior: Clip.hardEdge,
// child: ReplyMime(
// storedMessage: quotedMessage!, model: model),
// ),
// ),
// Container(
// width: 20,
// padding: const EdgeInsets.all(2.0),
// child: GestureDetector(
// key: const ValueKey('close_reply'),
// onTap: () => onCloseListener(),
// child: const Icon(Icons.close, size: 20),
// ),
// ),
// ],
// ),
