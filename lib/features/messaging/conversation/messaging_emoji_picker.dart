import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as ep;
import 'package:lantern/core/utils/common.dart';

class MessagingEmojiPicker extends StatelessWidget {
  final double height;
  final String emptySuggestions;
  final Function(ep.Category?, ep.Emoji) onEmojiSelected;
  final VoidCallback? onBackspacePressed;

  const MessagingEmojiPicker({
    required this.height,
    required this.emptySuggestions,
    this.onBackspacePressed,
    required this.onEmojiSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 8.0,
              end: 8.0,
              bottom: 8.0,
            ),
            child: ep.EmojiPicker(
              key: key,
              onBackspacePressed: onBackspacePressed,
              onEmojiSelected: onEmojiSelected,
              config: ep.Config(
                checkPlatformCompatibility: true,
                categoryViewConfig: ep.CategoryViewConfig(
                  initCategory: ep.Category.SMILEYS,
                  iconColor: grey5,
                  iconColorSelected: black,
                  indicatorColor: grey5,
                ),
                emojiViewConfig: ep.EmojiViewConfig(
                  columns: constraints.maxWidth ~/ 50.0,
                  backgroundColor: white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
