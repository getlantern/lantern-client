import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/messaging.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class ImageAttachment extends VisualAttachment {
  ImageAttachment(Contact contact, StoredMessage message,
      StoredAttachment attachment, bool inbound)
      : super(contact, message, attachment, inbound);

  @override
  Widget buildViewer(MessagingModel model) =>
      ImageViewer(model, contact, message, attachment);
}

class ImageViewer extends ViewerWidget {
  final MessagingModel model;
  final StoredAttachment attachment;

  ImageViewer(
      this.model, Contact contact, StoredMessage message, this.attachment)
      : super(contact, message);

  @override
  State<StatefulWidget> createState() => ImageViewerState();
}

class ImageViewerState extends ViewerState<ImageViewer> {
  BasicMemoryImage? image;

  @override
  void initState() {
    super.initState();
    widget.model.decryptAttachment(widget.attachment).then((bytes) {
      BasicMemoryImage? newImage = BasicMemoryImage(bytes);
      newImage.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((info, _) {
        if (info.image.width > info.image.height) {
          forceLandscape();
        }
      }));
      setState(() => image = newImage);
    });
  }

  @override
  bool ready() => image != null;

  @override
  Widget body(BuildContext context) => Align(
        alignment: Alignment.center,
        child: PinchZoom(
          resetDuration: const Duration(milliseconds: 100),
          maxScale: 2.5,
          child: image!,
        ),
      );
}
