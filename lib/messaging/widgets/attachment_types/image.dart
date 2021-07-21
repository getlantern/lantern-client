import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class ImageAttachment extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;

  ImageAttachment(this.attachment, this.inbound);

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    switch (attachment.status) {
      case StoredAttachment_Status.PENDING_UPLOAD:
      case StoredAttachment_Status.PENDING:
        // pending download
        return Transform.scale(
            scale: 0.5,
            child: CircularProgressIndicator(
                color: inbound ? inboundMsgColor : outboundMsgColor));
      case StoredAttachment_Status.FAILED:
        // error with download
        return Icon(Icons.error_outlined,
            color: inbound ? inboundMsgColor : outboundMsgColor);
      case StoredAttachment_Status.DONE:
        // successful download, onto decrypting
        return Container(
          child: FutureBuilder(
              future: model.thumbnail(attachment),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Icon(Icons.error_outlined,
                          color: inbound ? inboundMsgColor : outboundMsgColor);
                    }
                    return Image.memory(snapshot.data,
                        errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) =>
                            Icon(Icons.error_outlined,
                                color: inbound
                                    ? inboundMsgColor
                                    : outboundMsgColor),
                        filterQuality: FilterQuality.high,
                        scale: 3);
                  default:
                    return Transform.scale(
                        scale: 0.5,
                        child: CircularProgressIndicator(
                          color: inbound ? inboundMsgColor : outboundMsgColor,
                        ));
                }
              }),
        );
      default:
        return Icon(Icons.error_outlined,
            color: inbound ? inboundMsgColor : outboundMsgColor);
    }
  }
}
