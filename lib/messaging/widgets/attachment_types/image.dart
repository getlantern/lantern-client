import 'dart:typed_data';

import 'package:lantern/messaging/widgets/attachment_builder.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:sizer/sizer.dart';

class ImageAttachment extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;

  ImageAttachment(this.attachment, this.inbound);

  @override
  Widget build(BuildContext context) {
    return AttachmentBuilder(
        attachment: attachment,
        inbound: inbound,
        defaultIcon: Icons.image,
        builder: (BuildContext context, Uint8List thumbnail) {
          return SizedBox(
            // this box keeps the image from being too tall
            height: 80.w,
            child: FittedBox(
              child: Image.memory(thumbnail,
                  errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) =>
                      Icon(Icons.error_outlined,
                          color: inbound ? inboundMsgColor : outboundMsgColor),
                  filterQuality: FilterQuality.high,
                  scale: 3),
            ),
          );
        });
  }
}
