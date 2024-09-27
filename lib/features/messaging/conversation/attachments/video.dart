import 'package:lantern/features/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/features/messaging/conversation/status_row.dart';
import 'package:lantern/features/messaging/messaging.dart';
import 'package:video_player/video_player.dart';

/// Base class for displaying a video attachment in Chat (conversation view as well as rendering the Video Viewer when that attachment is tapped). It extends VisualAttachment and overrides its buildViewer() and wrapThumbnail() functions.
class VideoAttachment extends VisualAttachment {
  VideoAttachment(
    Contact contact,
    StoredMessage message,
    StoredAttachment attachment,
    bool inbound,
  ) : super(contact, message, attachment, inbound);

  @override
  Widget buildViewer() => FullScreenVideoViewer(
        decryptVideoFile: messagingModel.decryptVideoForPlayback(attachment),
        loadVideoFile: (String path) => VideoPlayerController.file(
          File(path),
        ),
        title: CText(
          contact.displayNameOrFallback,
          style: tsHeading3.copiedWith(color: white),
        ),
        metadata: {
          'rotation': attachment.attachment.metadata['rotation'],
          'ts': Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, top: 8),
            child: StatusRow(
              message.direction == MessageDirection.OUT,
              message,
            ),
          )
        },
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
