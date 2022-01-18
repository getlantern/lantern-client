import 'package:lantern/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/messaging/messaging.dart';

import '../../../common/ui/custom/viewer.dart';

class ImageAttachment extends VisualAttachment {
  ImageAttachment(
    Contact contact,
    StoredMessage message,
    StoredAttachment attachment,
    bool inbound,
  ) : super(contact, message, attachment, inbound);

  @override
  Widget buildViewer() =>
      ImageViewer(null, MessagingViewerProps(contact, message, attachment));
}

class ImageViewer extends ViewerWidget {
  @override
  final ReplicaViewerProps? replicaProps;
  @override
  final MessagingViewerProps? messagingProps;

  ImageViewer(this.replicaProps, this.messagingProps)
      : super(replicaProps, messagingProps, null, null);

  @override
  State<StatefulWidget> createState() => ImageViewerState();
}

class ImageViewerState extends ViewerState<ImageViewer> {
  BasicMemoryImage? image;

  @override
  void initState() {
    super.initState();
    messagingModel
        .decryptAttachment(widget.messagingProps!.attachment)
        .then((bytes) {
      BasicMemoryImage? newImage = BasicMemoryImage(bytes);
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
