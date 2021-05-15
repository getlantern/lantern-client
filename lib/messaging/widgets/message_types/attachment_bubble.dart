import 'package:lantern/messaging/widgets/attachment.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';

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
    final attachments = msg.attachments.values
        .map((attachment) => attachmentWidget(attachment));
    return Column(
        crossAxisAlignment:
            outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              constraints: const BoxConstraints(
                minWidth: 90,
              ),
              decoration: BoxDecoration(
                color: outbound ? Colors.black38 : Colors.black12,
                borderRadius: BorderRadius.only(
                  topLeft: inbound && !startOfBlock
                      ? Radius.zero
                      : const Radius.circular(5),
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
              child: Column(
                crossAxisAlignment: outbound
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 4, bottom: 4, left: 8, right: 8),
                      child: Column(
                          crossAxisAlignment: outbound
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [...attachments]),
                          ])),
                  StatusRow(outbound, inbound, reactions, msg, message)
                ],
              )),
        ]);
  }
}
