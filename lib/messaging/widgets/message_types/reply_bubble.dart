import 'package:lantern/messaging/widgets/message_types/text_bubble.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';

class ReplyBubble extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final StoredMessage? quotedMessage;

  const ReplyBubble(
    this.outbound,
    this.inbound,
    this.msg,
    this.message,
    this.quotedMessage,
  ) : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'In response to: ${quotedMessage!.text}',
                style: TextStyle(color: Colors.cyan // TODO: generalize in theme
                    ),
              ),
            ),
            Flexible(
              child: Text(
                'Response: ${msg.text}',
                style: TextStyle(color: Colors.pink // TODO: generalize in theme
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
