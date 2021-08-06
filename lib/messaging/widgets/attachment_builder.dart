import 'dart:typed_data';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:sizer/sizer.dart';

/// AttachmentBuilder is a builder for attachments that handles progress
/// indicators, error indicators and maximizing the displayed size
/// given constraints.
class AttachmentBuilder extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;
  final bool
      maximized; // set to true to make attachment use all available space in the message bubble
  final IconData
      defaultIcon; // the icon to display while we're waiting to fetch the thumbnail
  final Widget Function(BuildContext context, Uint8List thumbnail) builder;

  AttachmentBuilder(
      {Key? key,
      required this.attachment,
      required this.inbound,
      this.maximized = false,
      required this.defaultIcon,
      required this.builder});

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    // we are first downloading attachments and then decrypting them by calling
    // _getDecryptedAttachment() in the FutureBuilder
    switch (attachment.status) {
      case StoredAttachment_Status.PENDING_UPLOAD:
        // pending download
        return Transform.scale(
          scale: 0.5,
          child: CircularProgressIndicator(
            color: inbound ? inboundMsgColor : outboundMsgColor,
          ),
        );
      case StoredAttachment_Status.FAILED:
        // error with download
        return Icon(Icons.error_outlined,
            color: inbound ? inboundMsgColor : outboundMsgColor);
      default:
        // successful download/upload, on to decrypting
        return FutureBuilder(
          future: model.thumbnail(attachment),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Transform.scale(
                scale: 0.5,
                child: CircularProgressIndicator(
                    color: inbound ? inboundMsgColor : outboundMsgColor),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Icon(Icons.error_outlined,
                    color: inbound ? inboundMsgColor : outboundMsgColor);
              }
              var result = builder(context, snapshot.data!!);
              if (maximized) {
                result = SizedBox(
                  width: 100.w,
                  child: FittedBox(
                    child: result,
                  ),
                );
              }
              return result;
            } else {
              return Icon(defaultIcon,
                  color: inbound ? inboundMsgColor : outboundMsgColor);
            }
          },
        );
    }
  }
}
