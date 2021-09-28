import 'package:lantern/messaging/messaging.dart';

class StatusRow extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage message;

  const StatusRow(this.outbound, this.inbound, this.message) : super();

  @override
  Widget build(BuildContext context) {
    final msgSelfDeletes = !message.disappearAt.isZero;
    final color = outbound ? outboundMsgColor : inboundMsgColor;
    return Container(
      padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 2.0),
            child: HumanizedDate.fromMillis(
              message.ts.toInt(),
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
                    child: message.status ==
                            StoredMessage_DeliveryStatus.COMPLETELY_SENT
                        ? CAssetImage(
                            path: ImagePaths.done_all,
                            size: 10,
                            color: color,
                          )
                        : message.status == StoredMessage_DeliveryStatus.SENDING
                            ? SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.5,
                                  color: color,
                                ),
                              )
                            : message.status ==
                                        StoredMessage_DeliveryStatus
                                            .COMPLETELY_FAILED ||
                                    message.status ==
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
                startMillis: message.firstViewedAt.toInt(),
                endMillis: message.disappearAt.toInt(),
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
