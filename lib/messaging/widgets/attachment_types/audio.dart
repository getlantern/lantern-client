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
    final Widget errorCaseWidget = Container(
      color: snippetBgIconColor,
      padding: const EdgeInsets.all(8.0),
      child: const Icon(
        Icons.error_outlined,
        size: 18,
        color: Colors.white,
      ),
    );

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
                Transform.scale(
                  scale: 0.5,
                  child: CircularProgressIndicator(
                    color: inbound ? inboundMsgColor : outboundMsgColor,
                  ),
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
                errorCaseWidget,
                Text(
                  'Audio/File not available'.i18n,
                  style: const TextStyle(color: Colors.white, fontSize: 15.0),
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
          width: MediaQuery.of(context).size.width * 0.5,
          waveHeight: 50,
        );
      default:
        return errorCaseWidget;
    }
  }
}
