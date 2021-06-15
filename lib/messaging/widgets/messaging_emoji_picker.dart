import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class MessagingEmojiPicker extends StatelessWidget {
  final bool showEmojis;
  final String emptySuggestions;
  final double height;
  final double width;
  final Function(Category, Emoji) onEmojiSelected;
  final VoidCallback? onBackspacePressed;

  const MessagingEmojiPicker({
    required this.showEmojis,
    required this.emptySuggestions,
    this.height = 200,
    this.onBackspacePressed,
    required this.width,
    required this.onEmojiSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedCrossFade(
        firstChild: const SizedBox(),
        secondChild: _showEmojiKeyBoard(context: context),
        firstCurve: Curves.easeIn,
        secondCurve: Curves.easeOut,
        reverseDuration: const Duration(milliseconds: 600),
        crossFadeState:
            !showEmojis ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 600),
      );

  Widget _showEmojiKeyBoard({required BuildContext context}) => Container(
        height: height,
        child: EmojiPicker(
          key: key,
          onBackspacePressed: onBackspacePressed,
          onEmojiSelected: onEmojiSelected,
          config: Config(
            initCategory: Category.SMILEYS,
            columns: 10,
            emojiSizeMax: 17.0,
            iconColor: Theme.of(context).primaryIconTheme.color ?? Colors.grey,
            iconColorSelected:
                Theme.of(context).accentIconTheme.color ?? Colors.blue,
            noRecentsStyle: Theme.of(context).textTheme.bodyText1 ??
                const TextStyle(fontSize: 16, color: Colors.black26),
            progressIndicatorColor: Theme.of(context).indicatorColor,
            noRecentsText: emptySuggestions,
            bgColor: Theme.of(context).backgroundColor,
            indicatorColor: Theme.of(context).indicatorColor,
          ),
        ),
      );
}
