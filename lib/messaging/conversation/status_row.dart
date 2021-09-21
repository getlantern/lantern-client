import 'package:lantern/messaging/messaging.dart';

class StatusRow extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;

  const StatusRow(this.outbound, this.inbound, this.msg, this.message)
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
            Container(
              padding: const EdgeInsets.only(right: 2.0),
              child: HumanizedDate.fromMillis(
                message.value.ts.toInt(),
                builder: (context, date) => CText(
                  date,
                  style: tsOverline.copiedWith(
                      color: outbound ? outboundMsgColor : inboundMsgColor),
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(right: 2.0),
                child: inbound
                    ? null
                    : msg.status == StoredMessage_DeliveryStatus.COMPLETELY_SENT
                        ? Icon(
                            Icons.check_circle_outline_outlined,
                            size: 12,
                            color:
                                outbound ? outboundMsgColor : inboundMsgColor,
                          )
                        : msg.status == StoredMessage_DeliveryStatus.SENDING
                            ? SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.5,
                                  color: outbound
                                      ? outboundMsgColor
                                      : inboundMsgColor,
                                ),
                              )
                            : msg.status ==
                                        StoredMessage_DeliveryStatus
                                            .COMPLETELY_FAILED ||
                                    msg.status ==
                                        StoredMessage_DeliveryStatus
                                            .PARTIALLY_FAILED
                                ? Icon(
                                    Icons.error_outline,
                                    size: 12,
                                    color: outbound
                                        ? outboundMsgColor
                                        : inboundMsgColor,
                                  )
                                : null),
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
