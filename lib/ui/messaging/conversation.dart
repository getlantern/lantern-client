import 'package:flutter/widgets.dart';
import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';

class Conversation extends StatefulWidget {
  Contact _contact;

  Conversation(this._contact) : super();

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  MessagingModel model;

  TextEditingController newMessage = TextEditingController();

  Widget buildMessage(
      BuildContext context,
      PathAndValue<ShortMessageRecord> message,
      ShortMessageRecord priorMessage,
      ShortMessageRecord nextMessage) {
    return model.message(context, message,
        (BuildContext context, ShortMessageRecord messageRecord, Widget child) {
      var msg = ShortMessage.fromBuffer(messageRecord.message);
      var outbound = messageRecord.direction == MessageDirection.OUT;
      var inbound = !outbound;

      var statusRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.5,
            child: Text(
              message.value.ts.toInt().humanizedDate(),
              style: TextStyle(
                color: outbound ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );

      var innerColumn = Column(
          crossAxisAlignment:
              outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                child: Text(
                  "${msg.text}",
                  style: TextStyle(
                    color: outbound ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ]),
            statusRow,
          ]);

      var statusIcon = inbound
          ? null
          : messageRecord.status == ShortMessageRecord_DeliveryStatus.SENDING
              ? Icons.pending_outlined
              : messageRecord.status ==
                          ShortMessageRecord_DeliveryStatus.COMPLETELY_FAILED ||
                      messageRecord.status ==
                          ShortMessageRecord_DeliveryStatus.PARTIALLY_FAILED
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
      return Row(
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
    });
  }

  _send(String text) {
    model.sendToDirectContact(widget._contact.id, text);
    newMessage.clear();
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();

    return BaseScreen(
      title: widget._contact.displayName.isEmpty
          ? widget._contact.id
          : widget._contact.displayName,
      body: Column(children: [
        Expanded(
          child: model.contactMessages(widget._contact, builder: (context,
              Iterable<PathAndValue<ShortMessageRecord>> messageRecords,
              Widget child) {
            return ListView.builder(
              reverse: true,
              itemCount: messageRecords.length,
              itemBuilder: (context, index) {
                return buildMessage(
                    context,
                    messageRecords.elementAt(index),
                    index >= messageRecords.length - 1
                        ? null
                        : messageRecords.elementAt(index + 1).value,
                    index == 0
                        ? null
                        : messageRecords.elementAt(index - 1).value);
              },
            );
          }),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Divider(height: 3),
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: TextFormField(
              textInputAction: TextInputAction.send,
              onFieldSubmitted: _send,
              controller: newMessage,
              decoration: InputDecoration(
                icon: Icon(Icons.emoji_emotions_outlined),
                suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      var text = newMessage.value.text;
                      if (text.isEmpty) {
                        return;
                      }
                      _send(text);
                    }),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Message'.i18n,
              )),
        ),
      ]),
    );
  }
}
