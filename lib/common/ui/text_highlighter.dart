import 'package:lantern/core/utils/common.dart';

class TextHighlighter extends StatelessWidget {
  const TextHighlighter({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  final String text;
  final CTextStyle style;

  @override
  Widget build(BuildContext context) {
    final fragments = text.split('**');
    final children = <TextSpan>[];
    for (var i = 1; i < fragments.length; i++) {
      children.add(
        TextSpan(
          text: fragments[i],
          style: i % 2 == 0
              ? style
              : style.copiedWith(color: pink4, fontWeight: FontWeight.w500),
        ),
      );
    }
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        text: fragments[0],
        style: style,
        children: children,
      ),
    );
  }
}
