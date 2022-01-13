import 'package:lantern/common/ui/custom/video_viewer.dart';
import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/messaging.dart';

class VideoAttachment extends VisualAttachment {
  VideoAttachment(
    Contact contact,
    StoredMessage message,
    StoredAttachment attachment,
    bool inbound,
  ) : super(contact, message, attachment, inbound);

  @override
  Widget buildViewer() => CVideoViewer(
        null,
        MessagingViewerProps(contact, message, attachment),
        CText(
          contact.displayNameOrFallback,
          style: tsHeading3.copiedWith(color: white),
        ),
        null,
      );

  @override
  Widget wrapThumbnail(Widget thumbnail) => Stack(
        alignment: Alignment.center,
        children: [
          thumbnail,
          PlayButton(
            size: 48,
            custom: true,
          )
        ],
      );
}
