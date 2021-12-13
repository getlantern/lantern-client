import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/messaging.dart';

import 'viewer.dart';

class ImageAttachment extends VisualAttachment {
  ImageAttachment(Contact contact, StoredMessage message,
      StoredAttachment attachment, bool inbound)
      : super(contact, message, attachment, inbound);

  @override
  Widget buildViewer() => ImageViewer(contact, message, attachment);
}

class ImageViewer extends ViewerWidget {
  final StoredAttachment attachment;

  ImageViewer(Contact contact, StoredMessage message, this.attachment)
      : super(contact, message);

  @override
  State<StatefulWidget> createState() => ImageViewerState();
}

class ImageViewerState extends ViewerState<ImageViewer> {
  BasicMemoryImage? image;

  @override
  void initState() {
    super.initState();
    messagingModel.decryptAttachment(widget.attachment).then((bytes) {
      BasicMemoryImage? newImage = BasicMemoryImage(bytes);
      // newImage.image.resolve(const ImageConfiguration()).addListener(
      //   ImageStreamListener(
      //     (info, _) {
      //       if (info.image.width > info.image.height) {
      //         forceLandscape();
      //       }
      //     },
      //   ),
      // );
      setState(() => image = newImage);
    });
  }

  @override
  bool ready() => image != null;

  @override
  Widget body(BuildContext context) => Align(
        alignment: Alignment.center,
        child: InteractiveViewer(
          child: image!,
        ),
      );
}
