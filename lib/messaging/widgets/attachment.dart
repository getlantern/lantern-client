import 'dart:typed_data';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/lru_cache.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:sizer/sizer.dart';

import 'attachment_types/audio.dart';
import 'attachment_types/generic.dart';
import 'attachment_types/image.dart';
import 'attachment_types/video.dart';

/// Factory for attachment widgets that can render the given attachment.
Widget attachmentWidget(StoredAttachment attachment, bool inbound) {
  final attachmentTitle = attachment.attachment.metadata['title'];
  final fileExtension = attachment.attachment.metadata['fileExtension'];
  final mimeType = attachment.attachment.mimeType;

  if (audioMimes.contains(mimeType)) {
    return AudioAttachment(attachment, inbound);
  }

  if (imageMimes.contains(mimeType)) {
    return ImageAttachment(attachment, inbound);
  }

  if (videoMimes.contains(mimeType)) {
    return VideoAttachment(attachment, inbound);
  }

  return _padded(GenericAttachment(
      attachmentTitle: attachmentTitle,
      fileExtension: fileExtension,
      inbound: inbound,
      icon: Icons.insert_drive_file_rounded));
}

/// AttachmentBuilder is a builder for attachments that handles progress
/// indicators, error indicators and maximizing the displayed size
/// given constraints.
class AttachmentBuilder extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;
  final bool
      maximized; // set to true to make attachment use all available space in the message bubble
  final bool padAttachment;
  final IconData
      defaultIcon; // the icon to display while we're waiting to fetch the thumbnail
  final Widget Function(BuildContext context, Uint8List thumbnail) builder;

  AttachmentBuilder(
      {Key? key,
      required this.attachment,
      required this.inbound,
      this.maximized = false,
      this.padAttachment = true,
      required this.defaultIcon,
      required this.builder});

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    // we are first downloading attachments and then decrypting them by calling
    // _getDecryptedAttachment() in the FutureBuilder
    switch (attachment.status) {
      case StoredAttachment_Status.PENDING:
        return _progressIndicator();
      case StoredAttachment_Status.FAILED:
        // error with download
        return _errorIndicator();
      case StoredAttachment_Status.PENDING_UPLOAD:
        continue alsoDone;
      alsoDone:
      case StoredAttachment_Status.DONE:
      default:
        // successful download/upload, on to decrypting
        return ValueListenableBuilder(
          valueListenable: model.thumbnail(attachment),
          builder: (BuildContext context,
              CachedValue<Uint8List> cachedThumbnail, Widget? child) {
            if (cachedThumbnail.loading) {
              return _progressIndicator();
            } else if (cachedThumbnail.error != null) {
              return _errorIndicator();
            } else if (cachedThumbnail.value != null) {
              var result = builder(context, cachedThumbnail.value!);
              if (maximized) {
                result = SizedBox(
                  width: 100.w,
                  child: FittedBox(
                    child: result,
                  ),
                );
              }
              if (padAttachment) {
                result = _padded(result);
              }
              return result;
            } else {
              return Icon(defaultIcon,
                  color: inbound ? inboundMsgColor : outboundMsgColor);
            }
          },
        );
    }
  }

  Widget _progressIndicator() {
    return _padded(
      Transform.scale(
        scale: 0.5,
        child: CircularProgressIndicator(
          color: inbound ? inboundMsgColor : outboundMsgColor,
        ),
      ),
    );
  }

  Widget _errorIndicator() {
    return _padded(
      Icon(Icons.error_outlined,
          color: inbound ? inboundMsgColor : outboundMsgColor),
    );
  }
}

Widget _padded(Widget child) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
    child: FittedBox(
      child: child,
    ),
  );
}
