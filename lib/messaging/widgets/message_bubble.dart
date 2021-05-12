import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';

import '../messaging_model.dart';
import 'message_utils.dart';
import 'attachment.dart';
import 'copied_text_widget.dart';
import 'message_types/deleted_bubble.dart';
import 'message_types/new_message_bubble.dart';
import 'message_types/reply_bubble.dart';
import 'message_types/date_marker_bubble.dart';

class MessageBubble extends StatelessWidget {
  final PathAndValue<StoredMessage> message;
  final StoredMessage? priorMessage;
  final StoredMessage? nextMessage;
  final Contact contact;

  MessageBubble(this.message, this.priorMessage, this.nextMessage, this.contact)
      : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.message(context, message,
        (BuildContext context, StoredMessage msg, Widget? child) {
      if (msg.firstViewedAt == 0) {
        model.markViewed(message);
      }

      var outbound = msg.direction == MessageDirection.OUT;
      var inbound = !outbound;
      var statusRow = Row(mainAxisSize: MainAxisSize.min, children: []);
      var wasDeleted = false; // TODO: infer that from msg
      var isReply = false; // TODO: infer that from msg
      var isDate =
          false; // TODO: calculate that from priorMessage and nextMessage

      // constructs a Map<emoticon, List<reactorName>>
      // example (key-value): ['😢', ['DisplayName1', 'DisplayName2']]
      var reactions = constructReactionsMap(msg, contact);
      reactions.forEach((key, value) {
        // only render this if the list of [reactorIds] is not empty
        if (value.isNotEmpty) {
          statusRow.children.add(Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                  // Tap on emoji to bring modal with breakdown of interactions
                  onTap: () =>
                      displayEmojiBreakdownPopup(context, msg, reactions),
                  child: displayEmojiCount(reactions, key))));
        }
      });
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

      var innerColumn = _buildInnerColumn(outbound, msg);
      // Render attachments
      innerColumn.children.addAll(msg.attachments.values
          .map((attachment) => attachmentWidget(attachment)));
      innerColumn.children.add(statusRow);

      final statusIcon = getStatusIcon(inbound, msg);
      if (statusIcon != null) {
        statusRow.children
            .add(Transform.scale(scale: .5, child: Icon(statusIcon)));
      }
      return InkWell(
          onLongPress: () {
            _buildActionsPopup(outbound, context, msg, model, reactions);
          },
          child: _buildRow(outbound, inbound, priorMessage, nextMessage,
              innerColumn, wasDeleted, isReply, isDate, msg));
    });
  }

  Future _buildActionsPopup(
      bool outbound,
      BuildContext context,
      StoredMessage msg,
      MessagingModel model,
      Map<String, List<dynamic>> reactions) {
    var reactionOptions = reactions.keys.toList();
    return showModalBottomSheet(
        context: context,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
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
                          color:
                              Colors.grey.shade200, // TODO generalize in theme
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
            CopiedTextWidget(message),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text('Delete for me'.i18n),
              onTap: () => _showDeleteDialog(context, model, true),
            ),
            // User's own messages
            if (outbound)
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: Text('Delete for everyone'.i18n),
                onTap: () => _showDeleteDialog(context, model, false),
              ),
          ]);
        });
  }

  Future<void> _showDeleteDialog(context, model, isLocal) async {
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

  Column _buildInnerColumn(bool outbound, StoredMessage msg) {
    return Column(
        crossAxisAlignment:
            outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            if (msg.text.isNotEmpty)
              Flexible(
                child: Text(
                  '${msg.text}',
                  style: TextStyle(
                    color: outbound ? Colors.white : Colors.black,
                  ),
                ),
              ),
          ]),
        ]);
  }

  Widget _buildRow(
    bool outbound,
    bool inbound,
    StoredMessage? priorMessage,
    StoredMessage? nextMessages,
    Column innerColumn,
    bool wasDeleted,
    bool isReply,
    bool isDate,
    StoredMessage msg,
  ) {
    var startOfBlock = priorMessage == null ||
        priorMessage.direction != message.value.direction;
    var endOfBlock = nextMessage == null ||
        nextMessage!.direction != message.value.direction;
    var newestMessage = nextMessage == null;
    return Row(
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
                  newestMessage,
                  innerColumn,
                  wasDeleted,
                  isReply,
                  isDate,
                  msg)),
        ),
      ],
    );
  }

  Widget _buildBubbleUI(
    bool outbound,
    bool inbound,
    bool startOfBlock,
    bool endOfBlock,
    bool newestMessage,
    Column innerColumn,
    bool wasDeleted,
    bool isReply,
    bool isDate,
    StoredMessage msg,
  ) {
    if (isDate) return DateMarker(msg);

    if (wasDeleted) return const DeletedMessage();

    if (isReply) {
      return ReplyMessage(outbound, inbound, startOfBlock, endOfBlock,
          newestMessage, innerColumn);
    }

    return NewMessage(outbound, inbound, startOfBlock, endOfBlock,
        newestMessage, innerColumn);
  }
}
