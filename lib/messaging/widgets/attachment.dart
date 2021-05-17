import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

import 'attachment_types/voice.dart';
import 'attachment_types/image.dart';
import 'attachment_types/video.dart';

/// Factory for attachment widgets that can render the given attachment.
Widget attachmentWidget(StoredAttachment attachment) {
  // https://developer.android.com/guide/topics/media/media-formats
  switch (attachment.attachment.mimeType) {
    case 'application/ogg':
    case 'audio/ogg':
      return Flexible(child: VoiceMemo(attachment));
    case 'audio/mp4':
    case 'audio/m4a':
    case 'audio/mkv':
    case 'audio/mp3':
    case 'audio/flac':
    case 'audio/mpeg':
      return Flexible(
          child: Column(
        children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: HexColor(borderColor),
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
                color: Colors.white,
              ),
              child: const Icon(Icons.audiotrack_rounded)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Text(
              'Audio file', // TODO: add i18n
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ));
    case 'image/jpeg':
    case 'image/png':
    case 'image/bpm':
    case 'image/gif':
    case 'image/webp':
    case 'image/wav':
    // TODO: check older platforms for HEIF
    case 'image/heif':
      return Flexible(child: ImageAttachment(attachment));
    case 'video/mp4':
    case 'video/mkv':
    case 'video/mov':
    case 'video/quicktime':
    case 'video/3gp':
    case 'video/webm':
      return Flexible(child: VideoAttachment(attachment));
    default:
      return Container();
  }
}
