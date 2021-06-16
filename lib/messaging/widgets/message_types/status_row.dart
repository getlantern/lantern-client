import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/utils/humanize.dart';

class StatusRow extends StatelessWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;

  const StatusRow(
    this.outbound,
    this.inbound,
    this.msg,
    this.message,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final statusIcon = getStatusIcon(inbound, msg);

    return Container(
        color: Colors.black54,
        width: 100,
        child: Opacity(
            opacity: 0.8,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Text(
                      message.value.ts.toInt().humanizeDate(),
                      style: tsMessageStatus(outbound),
                    ),
                  ),
                  if (statusIcon != null)
                    Container(
                        child: Transform.scale(
                            scale: .5,
                            child: Icon(
                              statusIcon,
                              color:
                                  outbound ? outboundMsgColor : inboundMsgColor,
                            ))),
                  Container(
                      child: CustomAssetImage(
                          path: ImagePaths.timer_12,
                          size: 14,
                          color: outbound ? outboundMsgColor : inboundMsgColor))
                ])));
  }
}
