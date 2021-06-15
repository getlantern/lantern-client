import 'package:flutter/material.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pbserver.dart';

class Reactions extends StatelessWidget {
  final List<String> reactionOptions;
  final MessagingModel messagingModel;
  final PathAndValue<StoredMessage> message;
  const Reactions(
      {required this.reactionOptions,
      required this.message,
      required this.messagingModel,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () async {
            await messagingModel.react(message, reactionOptions[index]);
            Navigator.pop(context);
          },
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: Text(
                reactionOptions[index],
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(
          width: 12.0,
        ),
        itemCount: reactionOptions.length,
      );
}
