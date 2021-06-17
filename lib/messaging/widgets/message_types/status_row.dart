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
    final begin = widget.msg.firstViewedAt.toInt();
    final end = widget.msg.disappearAt.toInt();
    final lifeSpan = end - begin;
    final step = lifeSpan / 12 + 1; // adding + 1 to avoid NaN below

    return TweenAnimationBuilder<int>(
        tween: IntTween(begin: begin, end: lifeSpan),
        duration: Duration(milliseconds: lifeSpan),
        curve: Curves.linear,
        builder: (BuildContext context, int time, Widget? child) {
          var index = (time / step).floor();
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
                                path: ImagePaths.countdownPaths[0],
                                size: 12,
                                color: widget.outbound
                                    ? outboundMsgColor
                                    : inboundMsgColor)),
                        Text(index.toString()),
                      ])));
        });
  }
}
