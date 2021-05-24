import 'package:audioplayers/audioplayers.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:pedantic/pedantic.dart';

/// An attachment that shows an audio player.
class VoiceMemo extends StatefulWidget {
  final StoredAttachment attachment;

  VoiceMemo(this.attachment);

  @override
  State<StatefulWidget> createState() {
    return VoiceMemoState();
  }
}

class VoiceMemoState extends State<VoiceMemo> {
  var _playing = false;

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    var audioPlayer = context.watch<AudioPlayer>();

    switch (widget.attachment.status) {
      case StoredAttachment_Status.PENDING_UPLOAD:
      case StoredAttachment_Status.PENDING_ENCRYPTION:
        return const Icon(Icons.pending_outlined);
      case StoredAttachment_Status.FAILED:
        return const Icon(Icons.error_outlined);
      case StoredAttachment_Status.DONE:
        return Transform.scale(
          scale: 1.5,
          child: IconButton(
            icon: Icon(_playing
                ? Icons.stop_circle_outlined
                : Icons.play_circle_outline),
            onPressed: () async {
              if (_playing) {
                await audioPlayer.stop();
                setState(() {
                  _playing = false;
                });
              } else {
                audioPlayer.onPlayerCompletion.listen((event) {
                  setState(() {
                    _playing = false;
                  });
                });
                var bytes = await model.decryptAttachment(widget.attachment);
                // TODO: playBytes only works on Android 23+. For older
                // platforms, we need to find another way to expose the data,
                // perhaps as a temp file or through a local HTTPS server (one
                // that uses disposable tokens for authentication so that other
                // apps can't access our content).
                unawaited(audioPlayer.playBytes(bytes).then((value) {
                  setState(() {
                    _playing = true;
                  });
                }));
              }
            },
          ),
        );
      default:
        return Container();
    }
  }
}
