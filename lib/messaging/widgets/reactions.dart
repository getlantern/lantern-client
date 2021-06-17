import 'package:flutter/material.dart';
import 'package:lantern/messaging/conversation.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';

class Reactions extends StatelessWidget {
  final List<String> reactionOptions;
  final MessagingModel messagingModel;
  final PathAndValue<StoredMessage> message;
  final ScrollController scrollController;
  final ShowEmojis onEmojiTap;
  const Reactions(
      {required this.reactionOptions,
      required this.message,
      required this.messagingModel,
      required this.scrollController,
      required this.onEmojiTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        controller: scrollController,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () async {
            if (reactionOptions[index] == '•••') {
              onEmojiTap(true, message);
              Navigator.pop(context);
              return;
            }
            await messagingModel.react(message, reactionOptions[index]);
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 2.0), //(x,y)
                  blurRadius: 2.0,
                ),
              ],
            ),
            child: CircleAvatar(
              child: Center(
                child: Text(
                  reactionOptions[index],
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(
          width: 7.0,
        ),
        itemCount: reactionOptions.length,
      );
}
