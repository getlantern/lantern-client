import 'package:lantern/features/messaging/messaging.dart';

Widget FullChatNumberWidget(BuildContext context, ChatNumber chatNumber) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        foregroundPainter: _FullChatNumberPainter(context, chatNumber),
      );
    },
  );
}

class _FullChatNumberPainter extends CustomPainter {
  final BuildContext context;
  final ChatNumber chatNumber;
  late final String short;
  late final String remainder;
  late final TextPainter shortPainter;
  late final TextPainter remainderPainter;
  late final double charWidth;
  late final double lineHeight;

  _FullChatNumberPainter(this.context, this.chatNumber) {
    short = '${chatNumber.shortNumber.formattedChatNumber} ';
    remainder = chatNumber.number.split(chatNumber.shortNumber)[1];
    shortPainter = TextPainter(
      text: TextSpan(text: short, style: tsBody2.copyWith(color: blue4)),
      textDirection: Directionality.of(context),
    );
    remainderPainter = TextPainter(
      text: TextSpan(text: remainder, style: tsBody2),
      textDirection: Directionality.of(context),
    );
    remainderPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );
    charWidth = remainderPainter.width / remainder.length;
    lineHeight = remainderPainter.height;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // layout and paint the short number
    shortPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    shortPainter.paint(canvas, Offset.zero);

    // figure out how much space is left on first line for the start of the
    // remainder
    final spaceOnFirstLine = size.width - shortPainter.width;
    final charactersOnFirstLine = (spaceOnFirstLine / charWidth).floor();

    // paint the start of the remainder on the first line
    remainderPainter.text = TextSpan(
      text: remainder.substring(0, charactersOnFirstLine),
      style: tsBody2,
    );
    remainderPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    remainderPainter.paint(canvas, Offset(shortPainter.width, 0));

    // paint additional lines with what's left of the remainder
    final charactersPerLine = (size.width / charWidth).floor();
    final lines =
        ((remainder.length - charactersOnFirstLine) / charactersPerLine).ceil();
    for (var line = 0; line < lines; line++) {
      final i = charactersOnFirstLine + line * charactersPerLine;
      remainderPainter.text = TextSpan(
        text: remainder.substring(
          i,
          min(remainder.length, i + charactersPerLine),
        ),
        style: tsBody2,
      );
      remainderPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      remainderPainter.paint(canvas, Offset(0, (line + 1) * lineHeight));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
