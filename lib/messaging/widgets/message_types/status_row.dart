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

    // final lifespan =
    //     (msg.disappearAt - DateTime.now().millisecondsSinceEpoch);
    // var step = (lifespan.toInt() / 12).round();
    // var remainingTime = lifespan.toInt() - step;
    // var index = (remainingTime / step).floor();

    return TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: 12),
        duration: const Duration(seconds: 10),
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
                            message.value.ts.toInt().humanizeDate(),
                            style: tsMessageStatus(outbound),
                          ),
                        ),
                        if (statusIcon != null)
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: Icon(
                                statusIcon,
                                size: 12,
                                color: outbound
                                    ? outboundMsgColor
                                    : inboundMsgColor,
                              )),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: CustomAssetImage(
                                path: ImagePaths.countdownPaths[index],
                                size: 12,
                                color: outbound
                                    ? outboundMsgColor
                                    : inboundMsgColor)),
                      ])));
        });
  }
}
