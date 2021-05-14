import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/utils/humanize.dart';

class StatusRow extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final Map<String, List<dynamic>> reactions;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;

  const StatusRow(
    this.outbound,
    this.inbound,
    this.reactions,
    this.msg,
    this.message,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final statusIcon = getStatusIcon(inbound, msg);
    final reactionsList = [];
    reactions.forEach((key, value) {
      if (value.isNotEmpty) {
        reactionsList.add(Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
                // Tap on emoji to bring modal with breakdown of interactions
                onTap: () =>
                    displayEmojiBreakdownPopup(context, msg, reactions),
                child: displayEmojiCount(reactions, key))));
      }
    });

    return Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
      ...reactionsList,
      Opacity(
        opacity: 0.5,
        child: Text(
          message.value.ts.toInt().humanizeDate(),
          style: TextStyle(
            color: outbound
                ? Colors.white
                : Colors.black, // TODO: consolidate colors here
            fontSize: 12,
          ),
        ),
      ),
      if (statusIcon != null)
        Transform.scale(scale: .5, child: Icon(statusIcon)),
    ]));
  }
}
