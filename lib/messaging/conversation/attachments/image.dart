import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/messaging.dart';

class ImageAttachment extends StatelessWidget {
  final Contact contact;
  final StoredMessage message;
  final StoredAttachment attachment;
  final bool inbound;

  ImageAttachment(this.contact, this.message, this.attachment, this.inbound);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return AttachmentBuilder(
          attachment: attachment,
          inbound: inbound,
          defaultIcon: Icons.image,
          scrimAttachment: true,
          onTap: () async => await context.router.push(
                FullScreenDialogPage(
                    widget: ImageViewer(model, contact, message, attachment)),
              ),
          builder: (BuildContext context, Uint8List thumbnail) {
            return ConstrainedBox(
              // this box keeps the image from being too tall
              constraints: BoxConstraints(maxHeight: constraints.maxWidth),
              child: FittedBox(
                child: BasicMemoryImage(
                  thumbnail,
                  errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) =>
                      CAssetImage(
                          path: ImagePaths.error_outline,
                          color: inbound ? inboundMsgColor : outboundMsgColor),
                ),
              ),
            );
          });
    });
  }
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
  Widget body(BuildContext context) => image!;
}
