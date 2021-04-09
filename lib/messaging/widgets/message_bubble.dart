import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';

import '../messaging_model.dart';
import 'attachment.dart';

class MessageBubble extends StatelessWidget {
  final PathAndValue<StoredMessage> message;
  final StoredMessage priorMessage;
  final StoredMessage nextMessage;

  MessageBubble(this.message, this.priorMessage, this.nextMessage) : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.message(context, message,
        (BuildContext context, StoredMessage msg, Widget child) {
      if (msg.firstViewedAt == 0) {
        model.markViewed(message);
      }

      var outbound = msg.direction == MessageDirection.OUT;
      var inbound = !outbound;

      var statusRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: msg.reactions.values
            .map((e) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(e.emoticon)) as Widget)
            .toList(),
      );
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

      var innerColumn = Column(
          crossAxisAlignment:
              outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (msg.text?.isNotEmpty)
                Flexible(
                  child: Text(
                    "${msg.text}",
                    style: TextStyle(
                      color: outbound ? Colors.white : Colors.black,
                    ),
                  ),
                ),
            ]),
          ]);

      innerColumn.children.addAll(msg.attachments.values
          .map((attachment) => attachmentWidget(attachment)));
      innerColumn.children.add(statusRow);

      var statusIcon = inbound
          ? null
          : msg.status == StoredMessage_DeliveryStatus.SENDING
              ? Icons.pending_outlined
              : msg.status == StoredMessage_DeliveryStatus.COMPLETELY_FAILED ||
                      msg.status ==
                          StoredMessage_DeliveryStatus.PARTIALLY_FAILED
                  ? Icons.error_outline
                  : null;
      if (statusIcon != null) {
        statusRow.children
            .add(Transform.scale(scale: .5, child: Icon(statusIcon)));
      }
      var startOfBlock = priorMessage == null ||
          priorMessage.direction != message.value.direction;
      var endOfBlock = nextMessage == null ||
          nextMessage.direction != message.value.direction;
      var newestMessage = nextMessage == null;
      var row = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            outbound ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                  left: outbound ? 20 : 4,
                  right: outbound ? 4 : 20,
                  top: 4,
                  bottom: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: outbound ? Colors.black38 : Colors.black12,
                  borderRadius: BorderRadius.only(
                    topLeft: inbound && !startOfBlock
                        ? Radius.zero
                        : Radius.circular(5),
                    topRight: outbound && !startOfBlock
                        ? Radius.zero
                        : Radius.circular(5),
                    bottomRight: outbound && (!endOfBlock || newestMessage)
                        ? Radius.zero
                        : Radius.circular(5),
                    bottomLeft: inbound && (!endOfBlock || newestMessage)
                        ? Radius.zero
                        : Radius.circular(5),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                  child: innerColumn,
                ),
              ),
            ),
          ),
        ],
      );

      return InkWell(
          child: row,
          onLongPress: () {
            showModalBottomSheet(
                context: context,
                isDismissible: true,
                builder: (context) {
                  return Wrap(children: [
                    if (msg.direction == MessageDirection.IN)
                      Row(
                        children: ['👍', '👎', '😄', '❤', '😢']
                            .map(
                              (e) => Padding(
                                padding: EdgeInsets.all(16),
                                child: InkWell(
                                  child: Transform.scale(
                                      scale: 2,
                                      child: Text(e,
                                          style: TextStyle(fontSize: 16))),
                                  onTap: () {
                                    model.react(message, e);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete for me'.i18n),
                      onTap: () {
                        model.deleteLocally(message);
                        Navigator.pop(context);
                      },
                    ),
                    if (msg.direction == MessageDirection.OUT)
                      ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete for everyone'.i18n),
                        onTap: () {
                          model.deleteGlobally(message);
                          Navigator.pop(context);
                        },
                      ),
                  ]);
                });
          });
    });
  }
}
