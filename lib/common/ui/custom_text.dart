import 'package:lantern/common/common.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? minFontSize;
  final TextOverflow overflow;

  /// A replacement for Text that includes the ability to auto-scale single-line
  /// text and place ellipses smartly.
  ///
  /// To auto-scale text, make sure to supply a style that includes a fontSize
  /// and supply a minFontSize that is less than the font size in the supplied
  /// style.
  CustomText(this.text,
      {this.style, this.minFontSize, this.overflow = TextOverflow.ellipsis});

  @override
  Widget build(BuildContext context) {
    if (style?.fontSize == null ||
        minFontSize == null ||
        style!.fontSize == minFontSize) {
      // Can't do special auto-scaling, just return regular Text
      return Text(text, style: style, overflow: overflow);
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final fontSize = _fontSizeFor(context, constraints.maxWidth);
      return Text(text,
          style: style!.copyWith(fontSize: fontSize), overflow: overflow);
    });
  }

  double _fontSizeFor(BuildContext context, double maxWidth) {
    final maxFontSize = style!.fontSize!;

    var textPainter =
        TextPainter(maxLines: 1, textDirection: Directionality.of(context));

    for (var fontSize = maxFontSize; fontSize >= minFontSize!; fontSize -= 2) {
      textPainter.text =
          TextSpan(text: text, style: style!.copyWith(fontSize: fontSize));
      textPainter.layout();
      if (textPainter.width <= maxWidth) {
        // text fits, use this size!
        return fontSize;
      }
    }

    // nothing fit, use the smallest size
    return minFontSize!;
  }
}
