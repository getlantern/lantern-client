import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Restricts markdown to a single line
// https://github.com/flutter/flutter/issues/81739
class CMarkdownBody extends MarkdownWidget {
  const CMarkdownBody(
      {required String data,
      required MarkdownStyleSheet styleSheet,
      SyntaxHighlighter? syntaxHighlighter,
      MarkdownTapLinkCallback? onTapLink,
      String? imageDirectory})
      : super(
          data: data,
          styleSheet: styleSheet,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          imageDirectory: imageDirectory,
        );

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    var richText = _findWidgetOfType<RichText>(children!.first);
    if (richText != null) {
      return RichText(
          text: richText.text,
          textAlign: richText.textAlign,
          textDirection: richText.textDirection,
          softWrap: richText.softWrap,
          overflow: TextOverflow.clip,
          textScaleFactor: richText.textScaleFactor,
          maxLines: 1,
          locale: richText.locale);
    }

    return children.first;
  }

  T? _findWidgetOfType<T>(Widget widget) {
    if (widget is T) {
      return widget as T;
    }

    if (widget is MultiChildRenderObjectWidget) {
      var multiChild = widget;
      for (var child in multiChild.children) {
        return _findWidgetOfType<T>(child);
      }
    } else if (widget is SingleChildRenderObjectWidget) {
      var singleChild = widget;
      return _findWidgetOfType<T>(singleChild.child!);
    }

    return null;
  }
}
