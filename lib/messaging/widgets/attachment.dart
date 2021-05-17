import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

import 'attachment_types/audio.dart';
import 'attachment_types/image.dart';
import 'attachment_types/video.dart';

/// Factory for attachment widgets that can render the given attachment.
Widget attachmentWidget(StoredAttachment attachment) {
  // https://developer.android.com/guide/topics/media/media-formats
  switch (attachment.attachment.mimeType) {
    case 'audio/ogg':
    case 'audio/mp4':
    case 'audio/m4a':
    case 'audio/mkv':
    case 'audio/mp3':
    case 'audio/flac':
    case 'audio/mpeg':
      return Flexible(child: AudioAttachment(attachment));
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
      return Flexible(child: Container());
  }
}
