import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/conversation/status_row.dart';
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
                      Icon(Icons.error_outlined,
                          color: inbound ? inboundMsgColor : outboundMsgColor),
                ),
              ),
            );
          });
    });
  }
}

class ImageViewer extends StatefulWidget {
  final MessagingModel model;
  final Contact contact;
  final StoredMessage message;
  final StoredAttachment attachment;

  ImageViewer(this.model, this.contact, this.message, this.attachment);

  @override
  State<StatefulWidget> createState() => ImageViewerState();
}

class ImageViewerState extends State<ImageViewer> {
  BasicMemoryImage? image;
  bool showInfo = true;

  @override
  void initState() {
    super.initState();
    widget.model.decryptAttachment(widget.attachment).then((bytes) {
      BasicMemoryImage? newImage = BasicMemoryImage(bytes);
      newImage.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((info, _) {
        if (info.image.width > info.image.height) {
          // force landscape
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ]);
        }
      }));
      setState(() => image = newImage);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: CText(
        widget.contact.displayName,
        maxLines: 1,
        style: tsHeading3.copiedWith(color: white),
      ),
      padHorizontal: false,
      foregroundColor: white,
      backgroundColor: black,
      showAppBar: showInfo,
      body: GestureDetector(
        onTap: () => setState(() => showInfo = !showInfo),
        child: !showInfo && image != null
            ? Align(alignment: Alignment.center, child: image!)
            : Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: image == null ? Container() : image!),
                  Padding(
                      padding: const EdgeInsets.all(4),
                      child: StatusRow(true, widget.message)),
                ],
              ),
      ),
    );
  }
}
