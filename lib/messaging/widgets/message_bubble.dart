import 'package:lantern/messaging/widgets/message_types/date_marker_bubble.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_types/attachment_bubble.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/ui/widgets/copied_text_widget.dart';
import 'package:lantern/messaging/widgets/message_types/deleted_bubble.dart';
import 'package:lantern/messaging/widgets/message_types/text_bubble.dart';

class MessageBubble extends StatelessWidget {
  final PathAndValue<StoredMessage> message;
  final StoredMessage? priorMessage;
  final StoredMessage? nextMessage;
  final Contact contact;
  final Function(StoredMessage?) onReply;

  MessageBubble(this.message, this.priorMessage, this.nextMessage, this.contact,
      this.onReply)
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
      final startOfBlock = priorMessage == null ||
          priorMessage?.direction != message.value.direction;
      final endOfBlock = nextMessage == null ||
          nextMessage!.direction != message.value.direction;
      final newestMessage = nextMessage == null;

      // constructs a Map<emoticon, List<reactorName>> : ['😢', ['DisplayName1', 'DisplayName2']]
      final reactions = constructReactionsMap(msg, contact);
      final isDateMarker = determineDateSwitch(priorMessage, nextMessage);
      // TODO: infer that from msg
      final wasDeleted = false;
      final isAttachment = msg.attachments.isNotEmpty;

      return InkWell(
          onLongPress: () {
            _buildActionsPopup(outbound, context, msg, model, reactions,
                message, isAttachment, onReply);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                outbound ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                    padding: EdgeInsetsDirectional.only(
                        start: isDateMarker != ''
                            ? outbound
                                ? 20
                                : 4
                            : 4,
                        end: isDateMarker != ''
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
                      isDateMarker,
                      wasDeleted,
                      isAttachment,
                      newestMessage,
                      reactions,
                      msg,
                      message,
                    )),
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
    String? isDateMarker,
    bool wasDeleted,
    bool isAttachment,
    bool newestMessage,
    Map<String, List<dynamic>> reactions,
    StoredMessage msg,
    PathAndValue<StoredMessage> message,
  ) {
    if (wasDeleted)
      return const DeletedBubble(); //TODO: needs to be completed when https://github.com/getlantern/android-lantern/issues/105 is ready

    if (isDateMarker != '') return DateMarker(isDateMarker);

    if (isAttachment) {
      return AttachmentBubble(outbound, inbound, startOfBlock, endOfBlock,
          newestMessage, reactions, msg, message);
    }

    return TextBubble(outbound, inbound, startOfBlock, endOfBlock,
        newestMessage, reactions, msg, message, contact, isDateMarker);
  }
}

Future _buildActionsPopup(
  bool outbound,
  BuildContext context,
  StoredMessage msg,
  MessagingModel model,
  Map<String, List<dynamic>> reactions,
  PathAndValue<StoredMessage> message,
  bool isAttachment,
  Function(StoredMessage?) onReply,
) {
  var reactionOptions = reactions.keys.toList();
  return showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) {
        return Wrap(children: [
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
          if (!isAttachment)
            ListTile(
              leading: const Icon(Icons.reply),
              title: Text('Reply'.i18n),
              onTap: () {
                onReply(msg);
                Navigator.of(context).pop();
              },
            ),
          if (!isAttachment) CopiedTextWidget(message),
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text('Delete for me'.i18n),
            onTap: () {
              _showDeleteDialog(context, model, true, message);
              Navigator.of(context).pop();
            },
          ),
          // User's own messages
          if (outbound)
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: Text('Delete for everyone'.i18n),
              onTap: () {
                _showDeleteDialog(context, model, false, message);
                Navigator.of(context).pop();
              },
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
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          )
        ],
      );
    },
  );
}
