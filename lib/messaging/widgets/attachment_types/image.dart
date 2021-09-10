import 'dart:typed_data';

import 'package:lantern/messaging/widgets/attachment.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/basic_memory_image.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';

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
            return GestureDetector(
              onTap: () => context.router.push(const ImageVideoDetailPage()),
              child: ConstrainedBox(
                // this box keeps the video from being too tall
                constraints: BoxConstraints(maxHeight: constraints.maxWidth),
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [black, transparent],
                    ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height * 1.5));
                  },
                  blendMode: BlendMode.dstIn,
                  child: FittedBox(
                    child: BasicMemoryImage(
                      thumbnail,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) =>
                          Icon(Icons.error_outlined,
                              color:
                                  inbound ? inboundMsgColor : outboundMsgColor),
                    ),
                  ),
                ),
              ),
            );
          });
    });
  }
}
