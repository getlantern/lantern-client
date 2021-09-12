import 'package:flutter/material.dart';
import 'package:lantern/messaging/conversations/conversation.dart';
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
  Widget build(BuildContext context) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        final _buttonSize = constraints.maxWidth / 8;
        final buttonSize = Size(_buttonSize, _buttonSize);

        return Row(
          children: reactionOptions
              .map(
                (e) => Flexible(
                  child: TextButton(
                    key: ValueKey(e),
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
                      minimumSize: MaterialStateProperty.all<Size>(buttonSize),
                      fixedSize: MaterialStateProperty.all<Size>(buttonSize),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
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
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      });
}
