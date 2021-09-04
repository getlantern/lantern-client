import 'dart:typed_data';

import 'package:lantern/messaging/widgets/attachment.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/basic_memory_image.dart';

class ImageAttachment extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;

  ImageAttachment(this.attachment, this.inbound);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return AttachmentBuilder(
          attachment: attachment,
          inbound: inbound,
          defaultIcon: Icons.image,
          builder: (BuildContext context, Uint8List thumbnail) {
            return ConstrainedBox(
              // this box keeps the video from being too tall
              constraints: BoxConstraints(maxHeight: constraints.maxWidth),
              child: FittedBox(
                child: BasicMemoryImage(
                  thumbnail,
                  errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) =>
                      Icon(Icons.error_outlined,
                          color: inbound ? inboundMsgColor : outboundMsgColor),
                ),
              ),
            );
          });
    });
  }
}
