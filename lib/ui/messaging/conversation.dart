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
    nipRadius: 0,
    nipWidth: 1,
    nipHeight: 1,
    color: Colors.black12,
    borderColor: Colors.black,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, right: 50),
    alignment: Alignment.topLeft,
  );

  static const _styleMe = BubbleStyle(
    nip: BubbleNip.rightBottom,
    nipRadius: 0,
    nipWidth: 1,
    nipHeight: 1,
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
                        topLeft: outbound ? Radius.circular(5) : Radius.zero,
                        bottomRight:
                            outbound ? Radius.zero : Radius.circular(5),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.circular(5)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: outbound ? Colors.white : Colors.black,
                      ),
                    ),
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
