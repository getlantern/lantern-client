import 'package:flutter/material.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';

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
                child: GestureDetector(
                  onTap: () async {
                    if (e == '•••') {
                      onEmojiTap(true, message);
                      Navigator.pop(context);
                      return;
                    }
                    await messagingModel.react(message, e);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 2.0),
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      child: Center(
                        child: Text(
                          e,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
}
