import 'package:lantern/enums/mime_reply.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

extension EnumExtension on MimeTypes {
  String asString() => toString().split('.').last;
}

extension AttachmentExtension on Attachment {
  MimeTypes fromString() {
    if (mimeType == null || mimeType.isEmpty) return MimeTypes.EMPTY;
    if (mimeType == 'video') return MimeTypes.VIDEO;
    if (mimeType == 'application/ogg') return MimeTypes.AUDIO;
    return MimeTypes.OTHERS;
  }
}
