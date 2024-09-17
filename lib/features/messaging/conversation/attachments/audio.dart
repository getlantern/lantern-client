import 'package:lantern/features/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/features/messaging/conversation/audio/audio_widget.dart';
import 'package:lantern/features/messaging/messaging.dart';

/// An attachment that shows an audio player.
class AudioAttachment extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;

  AudioAttachment(
    this.attachment,
    this.inbound,
  );

  @override
  Widget build(BuildContext context) {
    return AttachmentBuilder(
      attachment: attachment,
      inbound: inbound,
      defaultIconPath: ImagePaths.speaker,
      builder: (BuildContext context, Uint8List thumbnail) {
        return AudioWidget(
          controller: AudioController(
            context: context,
            attachment: attachment,
            thumbnail: thumbnail,
          ),
          initialColor: inbound ? Colors.black : Colors.white,
          progressColor: inbound ? outboundMsgColor : inboundMsgColor,
          timeRemainingAlignment:
              inbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        );
      },
    );
  }
}
