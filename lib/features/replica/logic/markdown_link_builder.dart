import 'package:flutter/gestures.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';
import 'package:markdown/markdown.dart' as md;

// TODO: this is not currently used?
/// ReplicaLinkMarkdownElementBuilder matches all words (in a markdown text)
/// starting with the keyword 'replica://' and converts them to clickable links
/// (i.e., SelectableText) that runs 'runReplicaLink' when tapped
class ReplicaLinkMarkdownElementBuilder extends MarkdownElementBuilder {
  ReplicaLinkMarkdownElementBuilder({
    required this.openLink,
    this.replicaApi,
  }) : super();

  final void Function(ReplicaApi, ReplicaLink) openLink;
  final ReplicaApi? replicaApi;

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (replicaApi != null) {
      return doVisitElementAfter(element, preferredStyle, replicaApi!);
    }
    return (replicaModel.withReplicaApi).call(
      (context, replicaApi, child) =>
          doVisitElementAfter(element, preferredStyle, replicaApi),
    );
  }

  Widget doVisitElementAfter(
    md.Element element,
    TextStyle? preferredStyle,
    ReplicaApi replicaApi,
  ) {
    // print('Found potential replica link: ${element.textContent}');
    var text = element.textContent;
    if (!replicaApi.available) {
      // Replica not available, just display a regular text widget
      return plain(text);
    }

    var link = ReplicaLink.New('replica://$text');
    if (link == null) {
      // Failed to parse replica link: just display a regular text widget
      return plain(text);
    }

    // print('Found replica link: ${element.textContent}');
    return SelectableText.rich(
      TextSpan(
        // replica:// is stripped during the parsing. Put it back
        text: 'replica://${link.infohash}',
        recognizer: TapGestureRecognizer()
          ..onTap = () => openLink(replicaApi, link),
        style: const TextStyle(color: Colors.blue),
      ),
      textDirection: TextDirection.ltr,
    );
  }

  Widget plain(String text) {
    return RichText(
      text: TextSpan(
        recognizer: null,
        text: 'replica://$text',
        style: const TextStyle(color: Colors.black),
      ),
    );
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
