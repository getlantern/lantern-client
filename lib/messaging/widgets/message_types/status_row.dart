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
        // padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              message.value.ts.toInt().humanizeDate(),
              style: TextStyle(
                color: outbound ? outboundMsgColor : inboundMsgColor,
                fontSize: 10,
              ),
            ),
          ),
          if (statusIcon != null)
            Opacity(
                opacity: 0.8,
                child: Transform.scale(
                    scale: .5,
                    child: Icon(
                      statusIcon,
                      color: outbound ? outboundMsgColor : inboundMsgColor,
                    ))),
        ]));
  }
}
