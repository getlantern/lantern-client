import 'package:lantern/messaging/widgets/attachment.dart';
import 'package:lantern/messaging/widgets/message_types/reply_bubble.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:sizer/sizer.dart';

class ContentContainer extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final Contact contact;
  final Function(PathAndValue<StoredMessage>) onTapReply;
  final bool startOfBlock;
  final bool endOfBlock;
  final bool newestMessage;
  final Map<String, List<dynamic>> reactions;

  const ContentContainer(
    this.outbound,
    this.inbound,
    this.msg,
    this.message,
    this.contact,
    this.onTapReply,
    this.startOfBlock,
    this.endOfBlock,
    this.newestMessage,
    this.reactions,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final reactionsList = [];
    reactions.forEach(
      (key, value) {
        if (value.isNotEmpty) {
          reactionsList.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              // Tap on emoji to bring modal with breakdown of interactions
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () =>
                    displayEmojiBreakdownPopup(context, msg, reactions),
                child: displayEmojiCount(reactions, key),
              ),
            ),
          );
        }
      },
    );

    final attachments = msg.attachments.values
        .map((attachment) => attachmentWidget(attachment, inbound));

    return Container(
      constraints: BoxConstraints(minWidth: 30.w, maxWidth: 85.w),
      padding: const EdgeInsets.only(top: 4, bottom: 8, left: 8, right: 8),
      decoration: BoxDecoration(
        color: outbound ? outboundBgColor : inboundBgColor,
        borderRadius: BorderRadius.only(
          topLeft:
              inbound && !startOfBlock ? Radius.zero : const Radius.circular(8),
          topRight: outbound && !startOfBlock
              ? Radius.zero
              : const Radius.circular(8),
          bottomRight: outbound && (!endOfBlock || newestMessage)
              ? Radius.zero
              : const Radius.circular(8),
          bottomLeft: inbound && (!endOfBlock || newestMessage)
              ? Radius.zero
              : const Radius.circular(8),
        ),
      ),
      child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment:
              outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.replyToId.isNotEmpty)
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => onTapReply(message),
                      child: ReplyBubble(outbound, msg, contact),
                    ),
                ]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.text.isNotEmpty)
                    Flexible(
                      child: Text(
                        '${msg.text}',
                        style: tsMessageBody(outbound),
                      ),
                    ),
                ]),
            ...attachments,
            const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: outbound
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusRow(outbound, inbound, msg, message, reactionsList)
                ]),
          ]),
    );
  }
}
