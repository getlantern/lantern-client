import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

import 'attachment_types/generic.dart';
import 'attachment_types/voice.dart';
import 'attachment_types/image.dart';
import 'attachment_types/video.dart';

/// Factory for attachment widgets that can render the given attachment.
Widget attachmentWidget(StoredAttachment attachment, bool inbound) {
  final attachmentTitle = attachment.attachment.metadata['title'];
  final mimeType = attachment.attachment.mimeType;
  // https://developer.android.com/guide/topics/media/media-formats
  switch (mimeType) {
    case 'application/ogg':
    case 'audio/ogg':
    case 'audio/mp3':
    case 'audio/m4a':
    case 'audio/flac':
    case 'audio/aac':
      return Flexible(child: VoiceMemo(attachment, inbound));

    ///(LUIS): Im not quite sure if it's neccesary to sepparate the VoiceMemo from an audio format.
    /// at the end both are audio files.
    case 'audio/mp4':
    case 'audio/mkv':
    case 'audio/mpeg':
      return Flexible(
          child: GenericAttachment(
              attachmentTitle: attachmentTitle,
              inbound: inbound,
              icon: Icons.audiotrack));
    case 'image/jpeg':
    case 'image/png':
    case 'image/bpm':
    case 'image/gif':
    case 'image/webp':
    case 'image/wav':
    case 'image/heif':
    case 'image/heic':
      return Flexible(child: ImageAttachment(attachment, inbound));
    case 'video/mp4':
    case 'video/mkv':
    case 'video/mov':
    case 'video/quicktime':
    case 'video/3gp':
    case 'video/webm':
      return Flexible(child: VideoAttachment(attachment, inbound));
    default:
      // render generic file type as an icon
      return Flexible(
        child: GenericAttachment(
            attachmentTitle: attachmentTitle,
            inbound: inbound,
            icon: Icons.insert_drive_file_rounded),
      );
  }
}
