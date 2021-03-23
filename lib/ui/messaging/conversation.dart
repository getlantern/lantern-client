import 'package:bubble/bubble.dart';
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

  static const _styleThem = BubbleStyle(
    nip: BubbleNip.leftBottom,
    color: Colors.black12,
    borderColor: Colors.black,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, right: 50),
    alignment: Alignment.topLeft,
  );

  static const _styleMe = BubbleStyle(
    nip: BubbleNip.rightBottom,
    color: Colors.black38,
    borderColor: Colors.black,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, left: 50),
    alignment: Alignment.topRight,
  );

  Widget buildMessage(BuildContext context, ShortMessageRecord message) {
    return model.message(message,
        (BuildContext context, ShortMessageRecord messageRecord, Widget child) {
      var message = ShortMessage.fromBuffer(messageRecord.message);
      var outbound =
          messageRecord.direction == ShortMessageRecord_Direction.OUT;
      var row = Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          message.text,
          style: TextStyle(
            color: outbound ? Colors.white : Colors.black,
          ),
        )
      ]);
      switch (messageRecord.status) {
        case ShortMessageRecord_DeliveryStatus.FAILING:
          row.children.add(Icon(Icons.warning_amber_outlined));
          break;
        case ShortMessageRecord_DeliveryStatus.COMPLETELY_FAILED:
          row.children.add(Icon(Icons.error_outline));
          break;
        case ShortMessageRecord_DeliveryStatus.PARTIALLY_FAILED:
          row.children.add(Icon(Icons.error_outline));
          break;
      }
      return Bubble(style: outbound ? _styleMe : _styleThem, child: row);
    });
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
                return buildMessage(context, messageRecords[index]);
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
              controller: newMessage,
              decoration: InputDecoration(
                icon: Icon(Icons.emoji_emotions_outlined),
                suffixIcon: IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: () {
                      var text = newMessage.value.text;
                      if (text.isEmpty) {
                        return;
                      }
                      model.sendToDirectContact(widget._contact.id, text);
                      newMessage.clear();
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
