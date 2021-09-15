import 'dart:ui';

import 'package:lantern/common/common.dart';

class CustomText extends StatelessWidget {
  final String text;
  final CustomTextStyle? style;
  final TextOverflow overflow;

  /// A replacement for Text that includes the ability to auto-scale single-line
  /// text and place ellipses smartly.
  ///
  /// To auto-scale text, make sure to supply a style that includes a
  /// minFontSize in addition to a fontSize.
  CustomText(this.text, {this.style, this.overflow = TextOverflow.ellipsis});

  @override
  Widget build(BuildContext context) {
    if (style?.minFontSize == null) {
      // Can't do special auto-scaling, just return regular Text
      return Text(text, style: style, overflow: overflow);
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final fontSize = _fontSizeFor(context, constraints.maxWidth);
      // scale height to keep line height the same even though font size changed
      final height = style!.height == null
          ? null
          : style!.height! * style!.fontSize! / fontSize;
      return Text(text,
          style: style!.copyWith(fontSize: fontSize, height: height),
          overflow: overflow);
    });
  }

  double _fontSizeFor(BuildContext context, double maxWidth) {
    final maxFontSize = style!.fontSize!;

    var textPainter =
        TextPainter(maxLines: 1, textDirection: Directionality.of(context));

    for (var fontSize = maxFontSize;
        fontSize >= style!.minFontSize!;
        fontSize -= 2) {
      textPainter.text =
          TextSpan(text: text, style: style!.copyWith(fontSize: fontSize));
      textPainter.layout();
      if (textPainter.width <= maxWidth) {
        // text fits, use this size!
        return fontSize;
      }
    }

    // nothing fit, use the smallest size
    return style!.minFontSize!;
  }
}

/// Extends TextStyle to support a minFontSize for responsive text rendering.
///
/// If minFontSize is set, CustomTextStyle requires that fontSize and height
/// also be set and that fontSize be greater than minFontSize.
///
/// Instead of height, this takes a more useful fontHeight, which sets the
/// height to fontHeight / fontSize.
class CustomTextStyle extends TextStyle {
  final double? minFontSize;

  CustomTextStyle(
      {bool inherit = true,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      this.minFontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      double? letterSpacing,
      double? wordSpacing,
      TextBaseline? textBaseline,
      double? fontHeight,
      TextLeadingDistribution? leadingDistribution,
      Locale? locale,
      Paint? foreground,
      Paint? background,
      List<Shadow>? shadows,
      List<FontFeature>? fontFeatures,
      TextDecoration? decoration,
      Color? decorationColor,
      TextDecorationStyle? decorationStyle,
      double? decorationThickness,
      String? debugLabel,
      String? fontFamily,
      List<String>? fontFamilyFallback,
      String? package})
      : super(
          inherit: inherit,
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          textBaseline: textBaseline,
          height: fontHeight == null || fontSize == null
              ? null
              : fontHeight / fontSize,
          leadingDistribution: leadingDistribution,
          locale: locale,
          foreground: foreground,
          background: background,
          shadows: shadows,
          fontFeatures: fontFeatures,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationStyle: decorationStyle,
          decorationThickness: decorationThickness,
          debugLabel: debugLabel,
          fontFamily: fontFamily,
        ) {
    if (fontHeight != null) {
      if (fontSize == null) {
        throw Exception('fontHeight is $fontHeight, please also set fontSize');
      }
    }

    if (minFontSize != null) {
      if (fontSize == null) {
        throw Exception(
            'minFontSize is $minFontSize, please also set fontSize');
      } else if (fontSize < minFontSize!) {
        throw Exception(
            'fontSize $fontSize, minFontSize is $minFontSize, please set minFontSize to something less than fontSize');
      } else if (height == null) {
        throw Exception(
            'minFontSize is $minFontSize, please also set a height');
      }
    }
  }
}
