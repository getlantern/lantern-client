import 'package:lantern/config/mime_types.dart';
import 'package:lantern/messaging/conversation/replies/reply_mime.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

extension EnumExtension on MimeTypes {
  String asString() => toString().split('.').last;
}

extension AttachmentExtension on Attachment {
  MimeTypes fromString() {
    if (mimeType.isEmpty) return MimeTypes.EMPTY;
    if (audioMimes.contains(mimeType)) return MimeTypes.AUDIO;
    if (imageMimes.contains(mimeType)) return MimeTypes.IMAGE;
    if (videoMimes.contains(mimeType)) return MimeTypes.VIDEO;
    return MimeTypes.OTHERS;
  }
}
