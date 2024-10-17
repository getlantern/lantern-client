import 'package:lantern/features/messaging/conversation/mime_type.dart';
import 'package:lantern/features/messaging/messaging.dart';

import 'audio.dart';
import 'generic.dart';
import 'image.dart';
import 'video.dart';

/// Factory for attachment widgets that can render the given attachment.
Widget attachmentWidget(
  Contact contact,
  StoredMessage message,
  StoredAttachment attachment,
  bool inbound,
) {
  final attachmentTitle = attachment.attachment.metadata['title'];
  final fileExtension = attachment.attachment.metadata['fileExtension'];
  final mimeType = mimeTypeOf(attachment.attachment.mimeType);

  switch (mimeType) {
    case MimeType.AUDIO:
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 14, top: 10, end: 18),
        child: AudioAttachment(attachment, inbound),
      );
    case MimeType.IMAGE:
      return ImageAttachment(contact, message, attachment, inbound);
    case MimeType.VIDEO:
      return VideoAttachment(contact, message, attachment, inbound);
    default:
      return GenericAttachment(
        attachmentTitle: attachmentTitle,
        fileExtension: fileExtension,
        inbound: inbound,
      );
  }
}

/// AttachmentBuilder is a builder for attachments that handles progress
/// indicators, error indicators and maximizing the displayed size
/// given constraints.
class AttachmentBuilder extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;
  final bool scrimAttachment;
  final String?
      defaultIconPath; // the icon to display while we're waiting to fetch the thumbnail
  final Widget Function(BuildContext context, Uint8List thumbnail) builder;
  final void Function()? onTap;

  AttachmentBuilder({
    Key? key,
    required this.attachment,
    required this.inbound,
    this.scrimAttachment = false,
    this.defaultIconPath,
    required this.builder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // we are first downloading attachments and then decrypting them by calling _getDecryptedAttachment()
    switch (attachment.status) {
      case StoredAttachment_Status.PENDING:
        return progressIndicator();
      case StoredAttachment_Status.FAILED:
        // error with download
        return errorIndicator();
      case StoredAttachment_Status.PENDING_UPLOAD:
        continue alsoDone;
      alsoDone:
      case StoredAttachment_Status.DONE:
      default:
        // successful download/upload, on to decrypting
        return ValueListenableBuilder(
          valueListenable: messagingModel.thumbnail(attachment),
          builder: (
            BuildContext context,
            CachedValue<Uint8List> cachedThumbnail,
            Widget? child,
          ) {
            if (cachedThumbnail.loading) {
              return progressIndicator();
            } else if (cachedThumbnail.error != null) {
              return errorIndicator();
            } else if (cachedThumbnail.value != null) {
              var result = builder(context, cachedThumbnail.value!);
              if (scrimAttachment) {
                result = addScrim(result);
              }
              if (onTap != null) {
                result = GestureDetector(onTap: onTap, child: result);
              }
              return result;
            } else {
              return CAssetImage(
                path: defaultIconPath ?? ImagePaths.error_outline,
                color: inbound ? inboundMsgColor : outboundMsgColor,
              );
            }
          },
        );
    }
  }

  /// creates a scrim on top of attachments
  Widget addScrim(Widget child) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 1],
                colors: [scrimGrey.withOpacity(0), black.withOpacity(0.68)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget progressIndicator() {
    return Transform.scale(
      scale: 0.5,
      child: CircularProgressIndicator(
        color: inbound ? inboundMsgColor : outboundMsgColor,
      ),
    );
  }

  Widget errorIndicator() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        top: 16,
        bottom: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: CAssetImage(
              size: 20,
              path: ImagePaths.error_outline,
              color: inbound ? inboundMsgColor : outboundMsgColor,
            ),
          ),
          CText(
            'error_rendering_message'.i18n,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: tsBody3.copiedWith(
              color: inbound ? inboundMsgColor : outboundMsgColor,
              fontStyle: FontStyle.italic,
            ),
          )
        ],
      ),
    );
  }

  Widget buildVisualThumbnail(
    BuildContext context,
    Uint8List thumbnail,
    BoxConstraints constraints,
    Widget Function(Widget) wrap,
  ) {
    return ConstrainedBox(
      // this box keeps the image from being too tall
      constraints: BoxConstraints(
        maxHeight: constraints.maxWidth,
        minWidth: constraints.maxWidth,
      ),
      child: wrap(
        FittedBox(
          child: BasicMemoryImage(
            thumbnail,
            width: 2000,
            height: 2000,
            fit: BoxFit.cover,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) =>
                    CAssetImage(
              path: ImagePaths.error_outline,
              color: inbound ? inboundMsgColor : outboundMsgColor,
            ),
          ),
        ),
      ),
    );
  }
}

abstract class VisualAttachment extends StatelessWidget {
  final Contact contact;
  final StoredMessage message;
  final StoredAttachment attachment;
  final bool inbound;

  VisualAttachment(this.contact, this.message, this.attachment, this.inbound);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AttachmentBuilder(
          attachment: attachment,
          inbound: inbound,
          defaultIconPath: ImagePaths.insert_drive_file,
          scrimAttachment: true,
          onTap: () async {
            await context.pushRoute(
              FullScreenDialogPage(widget: buildViewer()),
            );
          },
          builder: (BuildContext context, Uint8List thumbnail) {
            return ConstrainedBox(
              // this box keeps the thumbnail from being too tall
              constraints: BoxConstraints(
                maxHeight: constraints.maxWidth,
                minWidth: constraints.maxWidth,
              ),
              child: wrapThumbnail(
                FittedBox(
                  child: BasicMemoryImage(
                    thumbnail,
                    width: 2000,
                    height: 2000,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) =>
                        Icon(
                      Icons.error_outlined,
                      color: inbound ? inboundMsgColor : outboundMsgColor,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildViewer();

  Widget wrapThumbnail(Widget thumbnail) => thumbnail;
}
