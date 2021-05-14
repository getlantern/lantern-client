import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';

class ContentContainer extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final Contact contact;
  final StoredMessage? quotedMessage;

  const ContentContainer(
    this.outbound,
    this.inbound,
    this.msg,
    this.message,
    this.contact,
    this.quotedMessage,
  ) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
        child: Column(
            crossAxisAlignment:
                outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (msg.replyToId.isNotEmpty)
                  Container(
                      constraints: const BoxConstraints(minWidth: 100),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.reply,
                                size: 14,
                              ),
                              Text(
                                matchIdToDisplayName(
                                    msg.replyToSenderId, contact),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: !outbound
                                      ? Colors.white
                                      : Colors
                                          .black, // TODO: generalize in theme
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                getMessageTextById(
                                    msg.replyToId, quotedMessage)!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: !outbound
                                      ? Colors.white
                                      : Colors
                                          .black, // TODO: generalize in theme
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (msg.text.isNotEmpty)
                  Flexible(
                    child: Text(
                      '${msg.text}',
                      style: TextStyle(
                        color: outbound
                            ? Colors.white
                            : Colors.black, // TODO: generalize in theme
                      ),
                    ),
                  ),
              ]),
            ]));
  }
}
