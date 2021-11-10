import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// ReplicaLinkBuilder matches all words (in a markdown text) starting with the
/// keyword 'replica://' and converts them to clickable links (i.e.,
/// SelectableText) that runs 'runReplicaLink' when tapped
class ReplicaLinkBuilder extends MarkdownElementBuilder {
  late Function(String) runReplicaLink;
  ReplicaLinkBuilder(this.runReplicaLink) : super();

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // print('Found replica link: $element.textContent');
    var text = element.textContent;
    return SelectableText.rich(
      TextSpan(
        text: 'replica://$text',
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            runReplicaLink(text);
          },
        style: const TextStyle(color: Colors.blue),
      ),
      textDirection: TextDirection.ltr,
    );
  }
}

class ReplicaLinkSyntax extends md.InlineSyntax {
  ReplicaLinkSyntax() : super(_pattern);

  // Regex breakdown:
  //
  // - 'replica:\/\/' matches 'replica://'
  // - '(\w.*?)(?=\s)'
  //   - runs a non-greedy match over all characters
  //   - while making sure that the first character of the group is a word
  //     character (i.e., not a space)
  //   - until the first space character is found.
  //   - Because of the positive lookahead, the first space character is not
  //     included in the match group
  //
  // Example:
  //
  //    replica://bunnyfoofoo will match to:
  //    match[0] = replica://bunnyfoofoo
  //    match[1] = bunnyfoofoo
  static final _pattern = r'.*replica:\/\/(\w.*?)(?=\s)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('replica', match[1]!));
    return true;
  }
}
