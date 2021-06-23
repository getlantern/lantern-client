import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:lantern/utils/stored_message_extension.dart';

class StatusRow extends StatefulWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final List reactionsList;

  const StatusRow(
      this.outbound, this.inbound, this.msg, this.message, this.reactionsList)
      : super();

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
    final segments = widget.msg.segments(iterations: 12);
    return TweenAnimationBuilder<int>(
        key: Key('tween_${widget.msg.id}'),
        tween: IntTween(begin: DateTime.now().millisecondsSinceEpoch, end: end),
        duration: Duration(milliseconds: lifeSpan),
        curve: Curves.linear,
        builder: (BuildContext context, int time, Widget? child) {
          var index = widget.msg.position(segments: segments);
          return Container(
            child: Opacity(
              opacity: 0.8,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                verticalDirection: VerticalDirection.up,
                children: [
                  ...widget.reactionsList,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Text(
                      widget.message.value.ts.toInt().humanizeDate(),
                      style: tsMessageStatus(widget.outbound),
                    ),
                  ),
                  if (statusIcon != null)
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
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
                            : inboundMsgColor),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
