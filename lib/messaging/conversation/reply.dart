import 'package:lantern/messaging/conversation/mime_type.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:lantern/vpn/vpn.dart';

class Reply extends StatelessWidget {
  final MessagingModel model;
  final Contact contact;
  final StoredMessage message;
  final void Function()? onCancel;

  const Reply({
    required this.model,
    required this.message,
    required this.contact,
    this.onCancel,
  }) : super();

  bool get isPreview => onCancel != null;

  bool get wasRemotelyDeleted => message.remotelyDeletedAt != 0;

  bool get isAttachment => message.attachments.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final body = buildBody();

    if (isPreview) {
      return Container(
        height: 68,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            body,
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: buildHeader(),
            ),
          ],
        ),
      );
    }

    return body;
  }

  Widget buildHeader() {
    return Row(
      mainAxisSize: isPreview ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (!isPreview)
          const Padding(
            padding: EdgeInsetsDirectional.only(end: 4),
            child: CAssetImage(
              path: ImagePaths.reply,
              size: 16,
            ),
          ),
        CText(
          'replying_to'
              .i18n
              .fill([replyToDisplayName(message.senderId, contact)]),
          maxLines: 1,
          style: tsSubtitle2,
        ),
      ],
    );
  }

  String replyToDisplayName(String contactIdToMatch, Contact contact) {
    return contactIdToMatch == contact.contactId.id
        ? contact.displayName
        : 'me'.i18n;
  }

  Widget buildBody() {
    return Container(
      height: 56,
      margin: isPreview ? const EdgeInsetsDirectional.only(top: 12) : null,
      padding: isPreview
          ? const EdgeInsetsDirectional.only(start: 16, end: 4)
          : const EdgeInsetsDirectional.only(start: 8),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: isPreview ? grey2 : white,
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
        mainAxisSize: isPreview ? MainAxisSize.max : MainAxisSize.min,
        children: [
          wrapBody(
            Padding(
              padding: EdgeInsetsDirectional.only(
                  end: 16, top: isPreview ? 12 : 4, bottom: 8),
              child: Column(
                mainAxisSize: isPreview ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isPreview) buildHeader(),
                  if (!isPreview) const Spacer(),
                  CText(
                    wasRemotelyDeleted
                        ? 'message_deleted'.i18n.fill([contact.displayName])
                        : isAttachment
                            ? attachmentText().i18n
                            : message.text,
                    maxLines: 1,
                    style: tsSubtitle1.short.copiedWith(
                        fontStyle: isAttachment || wasRemotelyDeleted
                            ? FontStyle.italic
                            : null),
                  ),
                ],
              ),
            ),
          ),
          if (isAttachment)
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
              onPressed: onCancel!,
            )
        ],
      ),
    );
  }

  Widget wrapBody(Widget body) {
    if (isPreview) {
      return Expanded(child: body);
    } else {
      return Flexible(child: body);
    }
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
    }
    return 'attachment';
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
            PlayButton(),
          ],
        );
    }
    return const CAssetImage(path: ImagePaths.insert_drive_file);
  }

  Widget thumbnail(StoredAttachment attachment) {
    return ValueListenableBuilder(
        valueListenable: model.thumbnail(attachment),
        builder: (BuildContext context, CachedValue<Uint8List> cachedThumbnail,
            Widget? child) {
          if (cachedThumbnail.value == null) {
            return const SizedBox();
          }
          return BasicMemoryImage(cachedThumbnail.value!,
              width: 56, height: 56, fit: BoxFit.cover);
        });
  }
}
