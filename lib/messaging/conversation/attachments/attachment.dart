import 'package:lantern/messaging/conversation/mime_types.dart';
import 'package:lantern/messaging/conversation/status_row.dart';
import 'package:lantern/messaging/messaging.dart';

import 'audio.dart';
import 'generic.dart';
import 'image.dart';
import 'video.dart';

/// Factory for attachment widgets that can render the given attachment.
Widget attachmentWidget(Contact contact, StoredMessage message,
    StoredAttachment attachment, bool inbound) {
  final attachmentTitle = attachment.attachment.metadata['title'];
  final fileExtension = attachment.attachment.metadata['fileExtension'];
  final mimeType = attachment.attachment.mimeType;

  if (audioMimes.contains(mimeType)) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 10, right: 18),
      child: AudioAttachment(attachment, inbound),
    );
  }

  if (imageMimes.contains(mimeType)) {
    return ImageAttachment(contact, message, attachment, inbound);
  }

  if (videoMimes.contains(mimeType)) {
    return VideoAttachment(contact, message, attachment, inbound);
  }

  return GenericAttachment(
      attachmentTitle: attachmentTitle,
      fileExtension: fileExtension,
      inbound: inbound,
      icon: Icons.insert_drive_file_rounded);
}

/// AttachmentBuilder is a builder for attachments that handles progress
/// indicators, error indicators and maximizing the displayed size
/// given constraints.
class AttachmentBuilder extends StatelessWidget {
  final StoredAttachment attachment;
  final bool inbound;
  final bool scrimAttachment;
  final IconData
      defaultIcon; // the icon to display while we're waiting to fetch the thumbnail
  final Widget Function(BuildContext context, Uint8List thumbnail) builder;
  final void Function()? onTap;

  AttachmentBuilder({
    Key? key,
    required this.attachment,
    required this.inbound,
    this.scrimAttachment = false,
    required this.defaultIcon,
    required this.builder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    // we are first downloading attachments and then decrypting them by calling _getDecryptedAttachment()
    switch (attachment.status) {
      case StoredAttachment_Status.PENDING:
        return progressIndicator();
      case StoredAttachment_Status.FAILED:
        // error with download
        return errorIndicator();
      case StoredAttachment_Status.PENDING_UPLOAD:
        continue alsoDone;
      alsoDone:
      case StoredAttachment_Status.DONE:
      default:
        // successful download/upload, on to decrypting
        return ValueListenableBuilder(
          valueListenable: model.thumbnail(attachment),
          builder: (BuildContext context,
              CachedValue<Uint8List> cachedThumbnail, Widget? child) {
            if (cachedThumbnail.loading) {
              return progressIndicator();
            } else if (cachedThumbnail.error != null) {
              return errorIndicator();
            } else if (cachedThumbnail.value != null) {
              var result = builder(context, cachedThumbnail.value!);
              if (scrimAttachment) {
                result = addScrim(result);
              }
              if (onTap != null) {
                result = GestureDetector(onTap: onTap, child: result);
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

  /// creates a scrim on top of attachments
  Widget addScrim(Widget child) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 1],
                colors: [scrimGrey.withOpacity(0), black.withOpacity(0.68)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget progressIndicator() {
    return Transform.scale(
      scale: 0.5,
      child: CircularProgressIndicator(
        color: inbound ? inboundMsgColor : outboundMsgColor,
      ),
    );
  }

  Widget errorIndicator() {
    return Icon(Icons.error_outlined,
        color: inbound ? inboundMsgColor : outboundMsgColor);
  }
}

/// Base class for widgets that allow viewing attachments like images and videos.
abstract class ViewerWidget extends StatefulWidget {
  final Contact contact;
  final StoredMessage message;

  ViewerWidget(this.contact, this.message);
}

/// Base class for state associated with ViewerWidgets.
abstract class ViewerState<T extends ViewerWidget> extends State<T> {
  bool showInfo = true;

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  bool ready();

  Widget body(BuildContext context);

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
        child: !showInfo && ready()
            ? Align(alignment: Alignment.center, child: body(context))
            : Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: !ready() ? Container() : body(context)),
                  Padding(
                      padding: const EdgeInsets.all(4),
                      child: StatusRow(true, widget.message)),
                ],
              ),
      ),
    );
  }

  void forceLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }
}
