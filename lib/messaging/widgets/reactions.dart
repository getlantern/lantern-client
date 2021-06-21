import 'package:flutter/material.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';
import 'package:lantern/package_store.dart';

class Reactions extends StatelessWidget {
  final List<String> reactionOptions;
  final MessagingModel messagingModel;
  final PathAndValue<StoredMessage> message;
  final ShowEmojis onEmojiTap;
  Reactions(
      {required this.reactionOptions,
      required this.message,
      required this.messagingModel,
      required this.onEmojiTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Flex(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        direction: Axis.horizontal,
        children: reactionOptions
            .map(
              (e) => Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextButton(
                    onPressed: () async {
                      if (e == '•••') {
                        onEmojiTap(true, message);
                        Navigator.pop(context);
                        return;
                      }
                      await messagingModel.react(message, e);
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) => states.contains(MaterialState.pressed)
                            ? Colors.white
                            : Colors.teal.withOpacity(0.1),
                      ),
                      elevation: MaterialStateProperty.resolveWith<double?>(
                        (states) {
                          return states.contains(MaterialState.pressed)
                              ? 4.0
                              : 0;
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      foregroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          return states.contains(MaterialState.pressed)
                              ? Colors.white
                              : Colors.teal.withOpacity(0.1);
                        },
                      ),
                    ),
                    child: Text(
                      e,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
}
