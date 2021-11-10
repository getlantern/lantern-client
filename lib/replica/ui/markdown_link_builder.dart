import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// ReplicaLinkMarkdownElementBuilder matches all words (in a markdown text)
/// starting with the keyword 'replica://' and converts them to clickable links
/// (i.e., SelectableText) that runs 'runReplicaLink' when tapped
class ReplicaLinkMarkdownElementBuilder extends MarkdownElementBuilder {
  late Function(ReplicaLink) runReplicaLink;
  ReplicaLinkMarkdownElementBuilder(this.runReplicaLink) : super();

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    print('XXX Found potential replica link: ${element.textContent}');
    var text = element.textContent;
    var link = ReplicaLink.New('replica://$text');
    if (link == null) {
      // Failed to parse replica link: just display a regular text widget
      return RichText(
          text: TextSpan(
              recognizer: null,
              text: 'replica://$text',
              style: const TextStyle(color: Colors.black)));
    }

    print('XXX Found replica link: ${element.textContent}');
    return SelectableText.rich(
      TextSpan(
        // replica:// is stripped during the parsing. Put it back
        text: 'replica://${link.infohash}',
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            runReplicaLink(link);
          },
        style: const TextStyle(color: Colors.blue),
      ),
      textDirection: TextDirection.ltr,
    );
    // return SelectableText.rich(
    //   TextSpan(
    //     // replica:// is stripped during the parsing. Put it back
    //     text: 'replica://${link.infohash}',
    //     recognizer: TapGestureRecognizer()
    //       ..onTap = () {
    //         runReplicaLink(link);
    //       },
    //     style: const TextStyle(color: Colors.blue),
    //   ),
    //   textDirection: TextDirection.ltr,
    // );
  }
}

class ReplicaLinkSyntax extends md.InlineSyntax {
  ReplicaLinkSyntax() : super(_pattern);

  // Regex breakdown:
  //
  // - \b matches assert position is at a word boundary (i.e., it's the start of
  //     a word in our case)
  // - 'replica:\/\/' matches 'replica://'
  // - '(\w.*?)(?=\s|$)'
  //   - runs a non-greedy (lazy) match over all characters
  //   - while making sure that the first character of the group is a word
  //     character (i.e., not a space)
  //   - until the first space character is found
  //     - or the end of the line
  //   - Because of the positive lookahead, the first space character is not
  //     included in the match group
  //
  // Example:
  //
  //    replica://bunnyfoofoo will match to:
  //    match[0] = replica://bunnyfoofoo
  //    match[1] = bunnyfoofoo
  static final _pattern = r'\breplica:\/\/(\w.*?)(?=\s|$)';

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('replica', match[1]!));
    return true;
  }
}
