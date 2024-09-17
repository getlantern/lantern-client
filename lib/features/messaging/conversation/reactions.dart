import 'package:lantern/features/messaging/messaging.dart';

class Reactions extends StatelessWidget {
  static final preferredEmojis = ['👍', '👎', '😂', '❤'];
  static final moreEmojis = '•••';
  static final clearReaction = '';

  final StoredMessage message;
  final void Function() onEmojiTap;

  Reactions({required this.message, required this.onEmojiTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return messagingModel.me((context, me, child) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final _buttonSize = constraints.maxWidth / 6;
          final buttonSize = Size(_buttonSize, _buttonSize);

          var emojis = List<String>.from(preferredEmojis);
          final myReaction = message.reactions[me.contactId.id];
          if (myReaction != null && !emojis.contains(myReaction.emoticon)) {
            // we already reacted and our reaction is not in the list, append it
            // to the list
            emojis = preferredEmojis.take(preferredEmojis.length - 1).toList() +
                [myReaction.emoticon];
          }
          emojis.add(moreEmojis);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: emojis.map((emoji) {
              final isMyReaction =
                  myReaction != null && myReaction.emoticon == emoji;
              return Flexible(
                child: TextButton(
                  key: ValueKey(emoji),
                  onPressed: () async {
                    unawaited(HapticFeedback.lightImpact());
                    if (emoji == '•••') {
                      onEmojiTap();
                      Navigator.pop(context);
                      return;
                    }
                    await messagingModel.react(
                      message,
                      isMyReaction ? clearReaction : emoji,
                    );
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (states) => white,
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => white,
                    ),
                    shadowColor: MaterialStateProperty.resolveWith<Color?>(
                      (states) =>
                          isMyReaction || states.contains(MaterialState.pressed)
                              ? black
                              : white,
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(buttonSize),
                    fixedSize: MaterialStateProperty.all<Size>(buttonSize),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsetsDirectional.all(1),
                    ),
                    elevation: MaterialStateProperty.resolveWith<double?>(
                      (states) {
                        final elevation =
                            states.contains(MaterialState.pressed) ? 4.0 : 1.0;
                        return isMyReaction ? elevation + 2 : elevation;
                      },
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                  child: CText(
                    emoji,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: tsEmoji.copiedWith(
                      fontSize: _buttonSize / 2,
                      lineHeight: _buttonSize / 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      );
    });
  }
}
