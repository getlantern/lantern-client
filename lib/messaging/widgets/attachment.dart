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
    return Flexible(
      child: AudioAttachment(attachment, inbound),
    );
  }
  if (imageMimes.contains(mimeType)) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
      child: Flexible(child: ImageAttachment(attachment, inbound)),
    );
  }
  if (videoMimes.contains(mimeType)) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
      child: Flexible(child: VideoAttachment(attachment, inbound)),
    );
  }
  return Flexible(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
      child: GenericAttachment(
          attachmentTitle: attachmentTitle,
          inbound: inbound,
          icon: Icons.insert_drive_file_rounded),
    ),
  );
}
