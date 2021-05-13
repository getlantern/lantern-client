import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

import '../messaging_model.dart';
import 'message_types/attachment_bubble.dart';
import 'message_utils.dart';
import 'copied_text_widget.dart';
import 'message_types/deleted_bubble.dart';
import 'message_types/text_bubble.dart';
import 'message_types/reply_bubble.dart';
import 'message_types/date_marker_bubble.dart';

class MessageBubbles extends StatelessWidget {
  final PathAndValue<StoredMessage> message;
  final StoredMessage? priorMessage;
  final StoredMessage? nextMessage;
  final Contact contact;

  MessageBubbles(
      this.message, this.priorMessage, this.nextMessage, this.contact)
      : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.message(context, message,
        (BuildContext context, StoredMessage msg, Widget? child) {
      if (msg.firstViewedAt == 0) {
        model.markViewed(message);
      }
      final outbound = msg.direction == MessageDirection.OUT;
      final inbound = !outbound;
      // constructs a Map<emoticon, List<reactorName>>
      // example (key-value): ['😢', ['DisplayName1', 'DisplayName2']]
      final reactions = constructReactionsMap(msg, contact);
      final isDate = determineDateSwitch(priorMessage, nextMessage);

      final startOfBlock = priorMessage == null ||
          priorMessage?.direction != message.value.direction;
      final endOfBlock = nextMessage == null ||
          nextMessage!.direction != message.value.direction;
      final newestMessage = nextMessage == null;

      return InkWell(
          onLongPress: () {
            _buildActionsPopup(
                outbound, context, msg, model, reactions, message);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                outbound ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                    padding: EdgeInsets.only(
                        left: !isDate
                            ? outbound
                                ? 20
                                : 4
                            : 4,
                        right: !isDate
                            ? outbound
                                ? 4
                                : 20
                            : 4,
                        top: 4,
                        bottom: 4),
                    child: _buildBubbleUI(
                        outbound,
                        inbound,
                        startOfBlock,
                        endOfBlock,
                        isDate,
                        newestMessage,
                        reactions,
                        msg,
                        message)),
              ),
            ],
          ));
    });
  }

  Widget _buildBubbleUI(
    bool outbound,
    bool inbound,
    bool startOfBlock,
    bool endOfBlock,
    bool isDate,
    bool newestMessage,
    Map<String, List<dynamic>> reactions,
    StoredMessage msg,
    PathAndValue<StoredMessage> message,
  ) {
    // TODO: infer that from msg
    final wasDeleted = false;
    // TODO: infer that from msg
    final isReply = false;
    final isAttachment = msg.attachments.isNotEmpty;
    if (isDate) return DateMarker();

    if (wasDeleted) return const DeletedBubble();

    if (isAttachment) {
      return AttachmentBubble(outbound, inbound, startOfBlock, endOfBlock,
          newestMessage, reactions, msg, message);
    }

    if (isReply) {
      return ReplyBubble(outbound, inbound, startOfBlock, endOfBlock,
          newestMessage, reactions, msg, message);
    }

    return TextBubble(outbound, inbound, startOfBlock, endOfBlock,
        newestMessage, reactions, msg, message);
  }
}

Future _buildActionsPopup(
  bool outbound,
  BuildContext context,
  StoredMessage msg,
  MessagingModel model,
  Map<String, List<dynamic>> reactions,
  PathAndValue<StoredMessage> message,
) {
  var reactionOptions = reactions.keys.toList();
  return showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) {
        return Wrap(children: [
          if (!outbound)
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
          // Other users' messages
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: reactionOptions
                .map((e) => Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200, // TODO generalize in theme
                        borderRadius:
                            const BorderRadius.all(Radius.circular(999)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: GestureDetector(
                          onTap: () {
                            model.react(message, e);
                            Navigator.pop(context);
                          },
                          child: Transform.scale(
                              scale: 1.2,
                              child: Text(e,
                                  style: const TextStyle(fontSize: 16))),
                        ),
                      ),
                    ))
                .toList(growable: false),
          ),
          if (!outbound)
            const Padding(
                padding: EdgeInsets.only(top: 8), child: Divider(height: 3)),
          ListTile(
            leading: const Icon(Icons.reply),
            title: Text('Reply'.i18n),
            onTap: () {},
          ),
          CopiedTextWidget(message), // TODO: hide this for attachments
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text('Delete for me'.i18n),
            onTap: () => _showDeleteDialog(context, model, true, message),
          ),
          // User's own messages
          if (outbound)
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: Text('Delete for everyone'.i18n),
              onTap: () => _showDeleteDialog(context, model, false, message),
            ),
        ]);
      });
}

Future<void> _showDeleteDialog(BuildContext context, MessagingModel model,
    bool isLocal, PathAndValue<StoredMessage> message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: isLocal
            ? const Text('Delete for me')
            : const Text('Delete for everyone'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              isLocal
                  ? const Text(
                      'This will delete the message for you only. Everyone else will still be able to see it.')
                  : const Text(
                      'This will delete the message for everyone.'), // TODO: i18n
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              isLocal
                  ? model.deleteLocally(message)
                  : model.deleteGlobally(message);
              Navigator.of(context)
                  .pop(); // TODO: close showModalBottomSheet as well
            },
            child: const Text('Delete'),
          )
        ],
      );
    },
  );
}
