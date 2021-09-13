import 'package:lantern/common/countdown_stopwatch.dart';
import 'package:lantern/common/humanized_date.dart';
import 'package:lantern/messaging/conversation/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';

class StatusRow extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final List reactionsList;

  const StatusRow(
      this.outbound, this.inbound, this.msg, this.message, this.reactionsList)
      : super();

  @override
  Widget build(BuildContext context) {
    final msgSelfDeletes = !msg.disappearAt.isZero;
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Opacity(
        opacity: 0.9,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...reactionsList,
            Container(
              padding: const EdgeInsets.only(right: 2.0),
              child: HumanizedDate.fromMillis(
                message.value.ts.toInt(),
                builder: (context, date) => Text(
                  date,
                  style: tsMessageStatus(outbound),
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(right: 2.0),
                child: renderStatusIcon(inbound, outbound, msg)),
            if (msgSelfDeletes)
              Container(
                padding: const EdgeInsets.only(right: 2.0),
                child: CountdownStopwatch(
                    startMillis: msg.firstViewedAt.toInt(),
                    endMillis: msg.disappearAt.toInt(),
                    color: outbound ? outboundMsgColor : inboundMsgColor),
              ),
          ],
        ),
      ),
    );
  }
}
