import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import '../attachment.dart';
import '../message_utils.dart';
import 'package:lantern/utils/humanize.dart';

class AttachmentBubble extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final bool startOfBlock;
  final bool endOfBlock;
  final bool newestMessage;
  final Map<String, List<dynamic>> reactions;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;

  const AttachmentBubble(
      this.outbound,
      this.inbound,
      this.startOfBlock,
      this.endOfBlock,
      this.newestMessage,
      this.reactions,
      this.msg,
      this.message)
      : super();

  @override
  Widget build(BuildContext context) {
    // Row that holds the reactions (if any) and the timestamp
    var statusRow = Row(mainAxisSize: MainAxisSize.min, children: []);
    // add reactions to statusRow
    reactions.forEach((key, value) {
      // only render this if the list of [reactorIds] is not empty
      if (value.isNotEmpty) {
        statusRow.children.add(Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
                // Tap on emoji to bring modal with breakdown of interactions
                onTap: () =>
                    displayEmojiBreakdownPopup(context, msg, reactions),
                child: displayEmojiCount(reactions, key))));
      }
    });
    // add timestamp to statusRow
    statusRow.children.add(Opacity(
      opacity: 0.5,
      child: Text(
        message.value.ts.toInt().humanizeDate(),
        style: TextStyle(
          color: outbound ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
    ));
    // add statusIcon to statusRow
    final statusIcon = getStatusIcon(inbound, msg);
    if (statusIcon != null) {
      statusRow.children
          .add(Transform.scale(scale: .5, child: Icon(statusIcon)));
    }

    // contains body of message
    var contentContainer = Column(
        crossAxisAlignment:
            outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: []);

    // add attachments to contentContainer
    //TODO: This is problematic because it re-renders every time
    contentContainer.children.addAll(msg.attachments.values
        .map((attachment) => attachmentWidget(attachment)));

    // add statusRow to contentContainer
    contentContainer.children.add(statusRow);

    return Container(
      decoration: BoxDecoration(
        color: outbound ? Colors.black38 : Colors.black12,
        borderRadius: BorderRadius.only(
          topLeft:
              inbound && !startOfBlock ? Radius.zero : const Radius.circular(5),
          topRight: outbound && !startOfBlock
              ? Radius.zero
              : const Radius.circular(5),
          bottomRight: outbound && (!endOfBlock || newestMessage)
              ? Radius.zero
              : const Radius.circular(5),
          bottomLeft: inbound && (!endOfBlock || newestMessage)
              ? Radius.zero
              : const Radius.circular(5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: contentContainer,
      ),
    );
  }
}
