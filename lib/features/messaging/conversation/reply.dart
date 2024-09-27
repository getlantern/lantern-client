import 'package:lantern/features/messaging/conversation/mime_type.dart';
import 'package:lantern/features/messaging/messaging.dart';

class Reply extends StatelessWidget {
  final Contact contact;
  final StoredMessage message;
  final bool isOutbound;
  final void Function()? onCancelReply;

  const Reply({
    required this.message,
    required this.contact,
    this.isOutbound = false,
    this.onCancelReply,
  }) : super();

  bool get isPreview => onCancelReply != null;

  bool get wasRemotelyDeleted => message.remotelyDeletedAt != 0;

  bool get isAttachment => message.attachments.isNotEmpty;

  bool get attachmentHasError =>
      message.attachments.isNotEmpty &&
      message.attachments[0]!.status == StoredAttachment_Status.FAILED;

  Color get foregroundColor => isOutbound ? white : black;

  @override
  Widget build(BuildContext context) {
    final body = buildBody(context);

    if (isPreview) {
      return Container(
        height: 68,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            body,
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: buildHeader(context),
            ),
          ],
        ),
      );
    }

    return body;
  }

  // "Replying to .... " segment
  Widget buildHeader(BuildContext context) {
    return Row(
      children: [
        if (!isPreview)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: mirrorLTR(
              context: context,
              child: CAssetImage(
                path: ImagePaths.reply,
                size: 16,
                color: foregroundColor,
              ),
            ),
          ),
        CText(
          isPreview
              ? 'replying_to'
                  .i18n
                  .fill([replyToDisplayName(message.senderId, contact)])
              : replyToDisplayName(message.senderId, contact),
          maxLines: 1,
          style: tsSubtitle2.copiedWith(color: foregroundColor),
        ),
      ],
    );
  }

  String replyToDisplayName(String contactIdToMatch, Contact contact) {
    return contactIdToMatch == contact.contactId.id
        ? contact.displayNameOrFallback
        : 'me'.i18n;
  }

  // Renders text if we are replying to a text
  // Renders mime type and thumbnail if we are replying to attachment
  Widget buildBody(BuildContext context) {
    return Container(
      height: 56,
      margin: isPreview ? const EdgeInsetsDirectional.only(top: 12) : null,
      padding: isPreview
          ? const EdgeInsetsDirectional.only(start: 16, end: 4)
          : const EdgeInsetsDirectional.only(start: 8),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: isPreview
            ? grey2
            : isOutbound
                ? blue5
                : white,
        borderRadius: isPreview
            ? null
            : const BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: isPreview
            ? null
            : [
                BoxShadow(
                  color: snippetShadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: 16,
                top: isPreview ? 12 : 4,
                bottom: 8,
              ),
              child: Column(
                mainAxisSize: isPreview ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isPreview) buildHeader(context),
                  if (!isPreview) const Spacer(),
                  CText(
                    wasRemotelyDeleted
                        ? 'message_deleted'
                            .i18n
                            .fill([contact.displayNameOrFallback])
                        : isAttachment
                            ? !attachmentHasError
                                ? attachmentText().i18n
                                : 'error_fetching_preview'.i18n
                            : message.text,
                    maxLines: 1,
                    style: tsSubtitle1.short.copiedWith(
                      color: foregroundColor,
                      fontStyle: isAttachment || wasRemotelyDeleted
                          ? FontStyle.italic
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isAttachment && !attachmentHasError)
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: grey4),
              child: attachmentWidget(),
            ),
          if (isPreview)
            IconButton(
              iconSize: 24,
              padding: EdgeInsetsDirectional.zero,
              icon: const CAssetImage(path: ImagePaths.delete),
              onPressed: onCancelReply!,
            )
        ],
      ),
    );
  }

  String attachmentText() {
    final mimeType = mimeTypeOf(message.attachments[0]!.attachment.mimeType);
    switch (mimeType) {
      case MimeType.AUDIO:
        return 'audio';
      case MimeType.IMAGE:
        return 'image';
      case MimeType.VIDEO:
        return 'video';
      default:
        return 'attachment';
    }
  }

  Widget attachmentWidget() {
    final attachment = message.attachments[0]!;
    final mimeType = mimeTypeOf(attachment.attachment.mimeType);
    switch (mimeType) {
      case MimeType.AUDIO:
        return const CAssetImage(path: ImagePaths.volume_up);
      case MimeType.IMAGE:
        return thumbnail(attachment);
      case MimeType.VIDEO:
        return Stack(
          alignment: Alignment.center,
          children: [
            thumbnail(attachment),
            PlayButton(custom: true),
          ],
        );
      default:
        return const CAssetImage(path: ImagePaths.insert_drive_file);
    }
  }

  Widget thumbnail(StoredAttachment attachment) {
    return ValueListenableBuilder(
      valueListenable: messagingModel.thumbnail(attachment),
      builder: (
        BuildContext context,
        CachedValue<Uint8List> cachedThumbnail,
        Widget? child,
      ) {
        if (cachedThumbnail.value == null) {
          return const SizedBox();
        }
        return BasicMemoryImage(
          cachedThumbnail.value!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
