import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/conversation_components/reactions.dart';
import 'package:lantern/messaging/widgets/message_types/deleted_bubble.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/message_position.dart';
import 'package:lantern/utils/show_alert_dialog.dart';

import 'message_types/content_container.dart';
import 'message_types/date_marker_bubble.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({
    Key? key,
    required this.message,
    required this.onBubbleReaction,
    required this.priorMessage,
    required this.nextMessage,
    required this.contact,
    required this.onReply,
    required this.onTapReply,
    required this.onEmojiTap,
  }) : super(key: key);

  final PathAndValue<StoredMessage> message;
  final ShowEmojis onEmojiTap;
  final StoredMessage? priorMessage;
  final StoredMessage? nextMessage;
  final Contact contact;
  final Function(StoredMessage?) onReply;
  final BubbleReactionCallback onBubbleReaction;
  final Function(PathAndValue<StoredMessage>) onTapReply;

  @override
  Widget build(BuildContext context) {
    Widget? reactionsList;
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
      reactionsList = constructReactionsList(context, reactions, msg);

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            outbound ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
                //OUTBOUND: SENDED MESSAGES.
                //INBOUND: RECEIVED MESSAGES
                padding: EdgeInsetsDirectional.only(
                  top: isDateMarker.isNotEmpty
                      ? 8
                      : MessagePosition.topPosition(reactionsList, nextMessage,
                          priorMessage, inbound, outbound),
                  start: inbound ? 16 : 0,
                  end: outbound ? 16 : 0,
                  bottom: MessagePosition.bottomPosition(reactionsList,
                      nextMessage, priorMessage, inbound, outbound),
                ),
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
                  reactionsList,
                )),
          ),
        ],
      );
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
    Widget? reactionsList,
  ) {
    if (wasDeleted) {
      final humanizedSenderName =
          matchIdToDisplayName(msg.remotelyDeletedBy.id, contact);
      return DeletedBubble('$humanizedSenderName deleted this message'.i18n);
    }

    return FocusedMenuHolder(
        menuItems: [
          FocusedMenuItem(
            title: Flexible(
              child: Reactions(
                onBubbleReaction: onBubbleReaction,
                onEmojiTap: onEmojiTap,
                reactionOptions: reactions.keys.toList(),
                message: message,
                messagingModel: model,
              ),
            ),
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
                showSnackbar(
                  context: context,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Text(
                        'Text Copied'.i18n,
                        style: txSnackBarText,
                        textAlign: TextAlign.left,
                      )),
                    ],
                  ),
                );
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
          if (outbound)
            FocusedMenuItem(
              trailingIcon: const Icon(Icons.delete_forever),
              title: Text('Delete for everyone'.i18n),
              onPressed: () async {
                await _showDeleteDialog(context, model, false, message);
              },
            ),
        ],
        blurBackgroundColor: Colors.blueGrey[900],
        menuOffset: 5.0,
        bottomOffsetHeight: 70.0,
        menuItemExtent: 60,
        openWithTap: false,
        duration: const Duration(seconds: 0),
        animateMenuItems: false,
        onPressed: () {},
        child: Column(
          crossAxisAlignment:
              outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isDateMarker != '')
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsetsDirectional.only(bottom: 10),
                  // width: 100.w,
                  child: DateMarker(isDateMarker)),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  child: ContentContainer(
                      priorMessage,
                      nextMessage,
                      outbound,
                      inbound,
                      msg,
                      message,
                      contact,
                      onTapReply,
                      startOfBlock,
                      endOfBlock,
                      newestMessage,
                      reactions,
                      isAttachment),
                ),
                reactionsList != null
                    ? PositionedDirectional(
                        top: -10,
                        end: inbound ? -13 : null,
                        start: outbound ? -13 : null,
                        child: reactionsList,
                      )
                    : const SizedBox(),
              ],
            )
          ],
        ));
  }
}

Future<void> _showDeleteDialog(BuildContext context, MessagingModel model,
    bool isLocal, PathAndValue<StoredMessage> message) async {
  showAlertDialog(
    context: context,
    key: const ValueKey('deleteDialog'),
    barrierDismissible: true,
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          isLocal
              ? Text(
                  'This will delete the message for you only. Everyone else will still be able to see it.'
                      .i18n,
                  style: tsAlertDialogBody)
              : Text('This will delete the message for everyone.'.i18n,
                  style: tsAlertDialogBody),
        ],
      ),
    ),
    title: isLocal
        ? Text('Delete for me', style: tsAlertDialogTitle)
        : Text('Delete for everyone', style: tsAlertDialogTitle),
    agreeAction: () =>
        isLocal ? model.deleteLocally(message) : model.deleteGlobally(message),
    agreeText: 'Delete',
  );
}
