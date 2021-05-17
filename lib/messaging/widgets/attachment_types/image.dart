import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class ImageAttachment extends StatelessWidget {
  final StoredAttachment attachment;

  ImageAttachment(this.attachment);

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    switch (attachment.status) {
      case StoredAttachment_Status.PENDING_UPLOAD:
      case StoredAttachment_Status.PENDING_ENCRYPTION:
        // pending download
        return const CircularProgressIndicator();
      case StoredAttachment_Status.FAILED:
        // error with download
        return const Icon(Icons.error_outlined);
      case StoredAttachment_Status.DONE:
        // successful download, onto decrypting
        return Container(
          child: FutureBuilder(
              future: model.thumbnail(attachment),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return const Icon(Icons.error_outlined);
                    }
                    return Image.memory(snapshot.data,
                        filterQuality: FilterQuality.high, scale: 3);
                  default:
                    return const CircularProgressIndicator();
                }
              }),
        );
      default:
        return Container();
    }
  }
}
