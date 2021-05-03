import 'package:audioplayers/audioplayers.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:pedantic/pedantic.dart';

/// Factory for attachment widgets that can render the given attachment.
Widget attachmentWidget(StoredAttachment attachment) {
  switch (attachment.attachment.mimeType) {
    case 'audio/ogg':
      return Flexible(child: _AudioAttachment(attachment));
    // https://developer.android.com/guide/topics/media/media-formats
    case 'image/jpeg':
    case 'image/png':
    case 'image/bpm':
    case 'image/gif':
    case 'image/webp':
    // TODO: check older platforms for HEIF
    case 'image/heif':
      return Flexible(child: _ImageAttachment(attachment));
    case 'video/*':
    // return Flexible(child: _VideoAttachment(attachment));
    default:
      // TODO: handle other types of attachments
      return Flexible(child: Container());
  }
}

class _ImageAttachment extends StatelessWidget {
  final StoredAttachment attachment;

  _ImageAttachment(this.attachment);

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    // we are first downloading attachments and then decrypting them by calling _getDecryptedAttachment() in the FutureBuilder
    switch (attachment.status) {
      case StoredAttachment_Status.PENDING_UPLOAD:
      case StoredAttachment_Status.PENDING_ENCRYPTION:
        // pending download
        return const CircularProgressIndicator();
      case StoredAttachment_Status.FAILED:
        // error with download
        return const Icon(Icons.error_outlined);
      case StoredAttachment_Status.DONE:
        // successful download, onto decrypting
        return Container(
          child: FutureBuilder(
              future: model.thumbnail(attachment),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return const Icon(Icons.error_outlined);
                    }
                    return Image.memory(snapshot.data,
                        filterQuality: FilterQuality.high, scale: 3);
                  default:
                    return const CircularProgressIndicator();
                }
              }),
        );
      default:
        return Container();
    }
  }
}

/// An attachment that shows an audio player.
class _AudioAttachment extends StatefulWidget {
  final StoredAttachment _attachment;

  _AudioAttachment(this._attachment);

  @override
  State<StatefulWidget> createState() {
    return _AudioAttachmentState();
  }
}

class _AudioAttachmentState extends State<_AudioAttachment> {
  var _playing = false;

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    var audioPlayer = context.watch<AudioPlayer>();

    switch (widget._attachment.status) {
      case StoredAttachment_Status.PENDING_UPLOAD:
        return const Icon(Icons.pending_outlined);
      case StoredAttachment_Status.FAILED:
        return const Icon(Icons.error_outlined);
      default:
        return Transform.scale(
          scale: 2,
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
                var bytes = await model.decryptAttachment(widget._attachment);
                // TODO: playBytes only works on Android 23+. For older platforms, we need to find another
                // way to expose the data, perhaps as a temp file or through a
                // local HTTPS server (one that uses disposable tokens for
                // authentication so that other apps can't access our content).
                unawaited(audioPlayer.playBytes(bytes).then((value) {
                  setState(() {
                    _playing = true;
                  });
                }));
              }
            },
          ),
        );
    }
  }
}
