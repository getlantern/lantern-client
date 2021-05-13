import 'package:lantern/messaging/widgets/message_types/text_bubble.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';

class ReplyBubble extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final bool startOfBlock;
  final bool endOfBlock;
  final bool newestMessage;
  final Map<String, List<dynamic>> reactions;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final StoredMessage quotedMessage;

  const ReplyBubble(
    this.outbound,
    this.inbound,
    this.startOfBlock,
    this.endOfBlock,
    this.newestMessage,
    this.reactions,
    this.msg,
    this.message,
    this.quotedMessage,
  ) : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'quoted text',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextBubble(outbound, inbound, startOfBlock, endOfBlock, newestMessage,
            reactions, msg, message)
      ],
    );
  }
}
