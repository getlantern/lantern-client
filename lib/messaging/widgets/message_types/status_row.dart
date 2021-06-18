import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:lantern/utils/int_extension.dart';

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
    final segments = widget.msg.firstViewedAt
        .toInt()
        .segments(iterations: 12, endTime: widget.msg.disappearAt.toInt());
    final begin = widget.msg.firstViewedAt.toInt();
    final end = widget.msg.disappearAt.toInt();
    final lifeSpan = end - begin;

    return TweenAnimationBuilder<int>(
        tween: IntTween(begin: begin, end: lifeSpan),
        duration: Duration(milliseconds: lifeSpan),
        curve: Curves.linear,
        builder: (BuildContext context, int time, Widget? child) {
          var index = begin.position(segments: segments, extraTime: time);
          return Container(
            child: Opacity(
              opacity: 0.8,
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Text(
                        widget.message.value.ts.toInt().humanizeDate(),
                        style: tsMessageStatus(widget.outbound),
                      ),
                    ),
                  ),
                  if (statusIcon != null)
                    Flexible(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Icon(
                            statusIcon,
                            size: 12,
                            color: widget.outbound
                                ? outboundMsgColor
                                : inboundMsgColor,
                          )),
                    ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: CustomAssetImage(
                          path: ImagePaths.countdownPaths[index],
                          size: 12,
                          color: widget.outbound
                              ? outboundMsgColor
                              : inboundMsgColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
