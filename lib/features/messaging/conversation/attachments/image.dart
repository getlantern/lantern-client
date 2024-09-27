import 'package:lantern/features/messaging/conversation/attachments/attachment.dart';
import 'package:lantern/features/messaging/conversation/status_row.dart';
import 'package:lantern/features/messaging/messaging.dart';

class ImageAttachment extends VisualAttachment {
  ImageAttachment(
    Contact contact,
    StoredMessage message,
    StoredAttachment attachment,
    bool inbound,
  ) : super(contact, message, attachment, inbound);

  @override
  Widget buildViewer() => FullScreenImageViewer(
        loadImageFile: messagingModel.decryptAttachment(attachment),
        title: CText(
          contact.displayNameOrFallback,
          style: tsHeading3.copiedWith(color: white),
        ),
        metadata: {
          'ts': Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, top: 8),
            child: StatusRow(
              message.direction == MessageDirection.OUT,
              message,
            ),
          )
        },
      );
}
