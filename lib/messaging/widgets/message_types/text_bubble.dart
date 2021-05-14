import 'package:lantern/messaging/widgets/message_types/content_container.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:lantern/messaging/widgets/message_types/date_marker_bubble.dart';

class TextBubble extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final bool startOfBlock;
  final bool endOfBlock;
  final bool newestMessage;
  final Map<String, List<dynamic>> reactions;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final Contact contact;
  final StoredMessage? quotedMessage;
  final String? isDateMarker;

  const TextBubble(
    this.outbound,
    this.inbound,
    this.startOfBlock,
    this.endOfBlock,
    this.newestMessage,
    this.reactions,
    this.msg,
    this.message,
    this.contact,
    this.quotedMessage,
    this.isDateMarker,
  ) : super();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment:
            outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // TODO: in theory this should appear before an attachment or deleted file as well
          if (isDateMarker != null) DateMarker(isDateMarker),
          Container(
              constraints: const BoxConstraints(maxWidth: 400),
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
                children: [
                  ContentContainer(
                      outbound, inbound, msg, message, contact, quotedMessage),
                  StatusRow(outbound, inbound, reactions, msg, message)
                ],
              )),
        ]);
  }
}
