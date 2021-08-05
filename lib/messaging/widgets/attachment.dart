import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

import 'attachment_types/generic.dart';
import 'attachment_types/audio.dart';
import 'attachment_types/image.dart';
import 'attachment_types/video.dart';

/// Factory for attachment widgets that can render the given attachment.
Widget attachmentWidget(StoredAttachment attachment, bool inbound) {
  final attachmentTitle = attachment.attachment.metadata['title'];
  final mimeType = attachment.attachment.mimeType;
  // https://developer.android.com/guide/topics/media/media-formats

  if (audioMimes.contains(mimeType)) {
    return AudioAttachment(attachment, inbound);
  }
  if (imageMimes.contains(mimeType)) {
    return ImageAttachment(attachment, inbound);
  }
  if (videoMimes.contains(mimeType)) {
    return VideoAttachment(attachment, inbound);
  }
  return GenericAttachment(
      attachmentTitle: attachmentTitle,
      inbound: inbound,
      icon: Icons.insert_drive_file_rounded);
}
