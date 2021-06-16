import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/utils/humanize.dart';
import 'dart:async';

class StatusRow extends StatefulWidget {
  final bool outbound;
  final bool inbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;

  StatusRow(
    this.outbound,
    this.inbound,
    this.msg,
    this.message,
  ) : super();

  @override
  _StatusRowState createState() => _StatusRowState();
}

class _StatusRowState extends State<StatusRow>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 4000), vsync: this);

    animation = Tween(begin: 4.00, end: 12.00).animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusIcon = getStatusIcon(widget.inbound, widget.msg);

    final lifespan =
        (widget.msg.disappearAt - DateTime.now().millisecondsSinceEpoch);
    var step = (lifespan.toInt() / 12).round();
    var remainingTime = lifespan.toInt() - step;
    var index = (remainingTime / step).floor();

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
                          path: ImagePaths.countdownPaths[0],
                          size: animation.value,
                          color: widget.outbound
                              ? outboundMsgColor
                              : inboundMsgColor)),
                ])));
  }
}
