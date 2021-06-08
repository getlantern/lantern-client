import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/ui/widgets/copied_text_widget.dart';
import 'package:lantern/messaging/widgets/message_types/deleted_bubble.dart';
import 'package:lantern/messaging/widgets/message_types/text_bubble.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    required this.priorMessage,
    required this.nextMessage,
    required this.contact,
    required this.onReply,
    required this.onTapReply,
  }) : super(key: key);

  final PathAndValue<StoredMessage> message;
  final StoredMessage? priorMessage;
  final StoredMessage? nextMessage;
  final Contact contact;
  final Function(StoredMessage?) onReply;
  final Function(PathAndValue<StoredMessage>) onTapReply;

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
      final wasDeleted = determineDeletionStatus(msg);
      final isAttachment = msg.attachments.isNotEmpty;

      return InkWell(
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
                  onTapReply,
                  context,
                  model,
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
    Function(PathAndValue<StoredMessage>) onTapReply,
    BuildContext context,
    MessagingModel model,
  ) {
    final reactionOptions = reactions.keys.toList();
    final reactionArray = reactionOptions
        .map((e) => Container(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    model.react(message, e);
                    Navigator.pop(context);
                  },
                  child: Transform.scale(
                      scale: 1.3,
                      child: Text(e, style: const TextStyle(fontSize: 16))),
                ),
              ),
            ))
        .toList(growable: false);

    if (wasDeleted) {
      final humanizedSenderName =
          matchIdToDisplayName(msg.remotelyDeletedBy.id, contact);
      return DeletedBubble(
          '$humanizedSenderName deleted this message for everyone'); // TODO: Add i18n
    }

    return FocusedMenuHolder(
        menuItems: [
          FocusedMenuItem(
            title: Row(children: [...reactionArray]),
            onPressed: () {},
          ),
          FocusedMenuItem(
            trailingIcon: const Icon(Icons.reply),
            title: Text('Reply'.i18n),
            onPressed: () {
              onReply(msg);
            },
          ),
          if (!isAttachment)
            FocusedMenuItem(
              trailingIcon: const Icon(Icons.copy),
              title: Text('Copy Text'.i18n),
              onPressed: () {
                showSnackbar(context, 'Text copied'.i18n);
                Clipboard.setData(ClipboardData(text: message.value.text));
              },
            ),
          FocusedMenuItem(
            trailingIcon: const Icon(Icons.delete),
            title: Text('Delete for me'.i18n),
            onPressed: () {
              _showDeleteDialog(context, model, true, message);
            },
          ),
          FocusedMenuItem(
            trailingIcon: const Icon(Icons.delete_forever),
            title: Text('Delete for everyone'.i18n),
            onPressed: () {
              _showDeleteDialog(context, model, false, message);
            },
          ),
        ],
        blurBackgroundColor: Colors.blueGrey[900],
        menuOffset: 10,
        menuItemExtent: 60,
        openWithTap: false,
        duration: const Duration(seconds: 0),
        animateMenuItems: false,
        onPressed: () {},
        child: TextBubble(
            outbound,
            inbound,
            startOfBlock,
            endOfBlock,
            newestMessage,
            reactions,
            msg,
            message,
            contact,
            onTapReply,
            isDateMarker));
  }
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
