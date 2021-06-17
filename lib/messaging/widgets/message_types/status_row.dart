import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/utils/humanize.dart';

class StatusRow extends StatefulWidget {
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
  StatusRowState createState() => StatusRowState();
}

class StatusRowState extends State<StatusRow> {
  @override
  Widget build(BuildContext context) {
    final statusIcon = getStatusIcon(widget.inbound, widget.msg);
    final lifespan = (widget.msg.disappearAt - widget.msg.firstViewedAt);

    return TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: 12),
        duration: Duration(milliseconds: lifespan.toInt()),
        curve: Curves.linear,
        builder: (BuildContext context, int index, Widget? child) {
          return Container(
              child: Opacity(
                  opacity: 0.8,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Text(
                            widget.message.value.ts.toInt().humanizeDate(),
                            style: tsMessageStatus(widget.outbound),
                          ),
                        ),
                        if (statusIcon != null)
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: Icon(
                                statusIcon,
                                size: 12,
                                color: widget.outbound
                                    ? outboundMsgColor
                                    : inboundMsgColor,
                              )),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: CustomAssetImage(
                                path: ImagePaths.countdownPaths[index],
                                size: 12,
                                color: widget.outbound
                                    ? outboundMsgColor
                                    : inboundMsgColor)),
                      ])));
        });
  }
}
