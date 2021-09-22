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
    final color = outbound ? outboundMsgColor : inboundMsgColor;
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 2.0),
            child: HumanizedDate.fromMillis(
              message.value.ts.toInt(),
              builder: (context, date) => CText(
                date,
                style: tsOverlineShort.copiedWith(color: color),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 2.0),
            child: inbound
                ? null
                : Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4),
                    child: msg.status ==
                            StoredMessage_DeliveryStatus.COMPLETELY_SENT
                        ? CAssetImage(
                            path: ImagePaths.done_all,
                            size: 10,
                            color: color,
                          )
                        : msg.status == StoredMessage_DeliveryStatus.SENDING
                            ? SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.5,
                                  color: color,
                                ),
                              )
                            : msg.status ==
                                        StoredMessage_DeliveryStatus
                                            .COMPLETELY_FAILED ||
                                    msg.status ==
                                        StoredMessage_DeliveryStatus
                                            .PARTIALLY_FAILED
                                ? CAssetImage(
                                    path: ImagePaths.error_outline,
                                    size: 10,
                                    color: color,
                                  )
                                : null),
          ),
          if (msgSelfDeletes)
            Container(
              padding: const EdgeInsetsDirectional.only(start: 4.0),
              child: CountdownStopwatch(
                startMillis: msg.firstViewedAt.toInt(),
                endMillis: msg.disappearAt.toInt(),
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
