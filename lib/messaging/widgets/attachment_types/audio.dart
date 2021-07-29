import 'package:lantern/messaging/widgets/voice_recorder/audio_widget.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

/// An attachment that shows an audio player.
class AudioAttachment extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;

  AudioAttachment(this.attachment, this.inbound);

  @override
  Widget build(BuildContext context) {
    switch (attachment.status) {
      case StoredAttachment_Status.PENDING_UPLOAD:
      case StoredAttachment_Status.PENDING:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 0.5,
                  color: inbound ? inboundMsgColor : outboundMsgColor,
                ),
              ],
            ),
          ],
        );
      case StoredAttachment_Status.FAILED:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline),
                const Text(
                  'Audio/File not available',
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ],
            ),
          ],
        );
      case StoredAttachment_Status.DONE:
        return AudioWidget(
          controller: AudioController(context, attachment),
          initialColor: inbound ? Colors.black : Colors.white,
          progressColor: inbound ? outboundMsgColor : inboundMsgColor,
          backgroundColor: inbound ? inboundBgColor : outboundBgColor,
        );
      default:
        return const SizedBox();
    }
  }
}
