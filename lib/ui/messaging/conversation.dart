import 'package:flutter/widgets.dart';
import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class Conversation extends StatefulWidget {
  Contact _contact;

  Conversation(this._contact) : super();

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  MessagingModel model;

  TextEditingController newMessage = TextEditingController();

  Widget buildMessage(BuildContext context, ShortMessageRecord message,
      ShortMessageRecord priorMessage, ShortMessageRecord nextMessage) {
    return model.message(message,
        (BuildContext context, ShortMessageRecord messageRecord, Widget child) {
      var msg = ShortMessage.fromBuffer(messageRecord.message);
      var outbound =
          messageRecord.direction == ShortMessageRecord_Direction.OUT;
      var inbound = !outbound;
      var innerRow = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              outbound ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                "${msg.text}",
                style: TextStyle(
                  color: outbound ? Colors.white : Colors.black,
                ),
              ),
            ),
          ]);
      if (outbound &&
          messageRecord.status == ShortMessageRecord_DeliveryStatus.SENDING) {
        innerRow.children.add(
            Transform.scale(scale: .5, child: Icon(Icons.pending_outlined)));
      }
      var startOfBlock =
          priorMessage == null || priorMessage.direction != message.direction;
      var endOfBlock =
          nextMessage == null || nextMessage.direction != message.direction;
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
                    child: innerRow,
                  ),
                ),
              ),
            ),
          ]);
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
          child: model.contactMessages(widget._contact, builder:
              (context, List<ShortMessageRecord> messageRecords, Widget child) {
            return ListView.builder(
              reverse: true,
              itemCount: messageRecords.length,
              itemBuilder: (context, index) {
                return buildMessage(
                    context,
                    messageRecords[index],
                    index >= messageRecords.length - 1
                        ? null
                        : messageRecords[index + 1],
                    index == 0 ? null : messageRecords[index - 1]);
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
