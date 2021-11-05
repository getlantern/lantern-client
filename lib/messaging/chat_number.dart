final shortChatNumberRegexOutside = RegExp(r'^(5*)([0-9]*)(5*)$');
final shortChatNumberRegexInside = RegExp(r'([0-9]{3})([0-9]{1,2}$)?');
final whitespace = RegExp(r'\s');
final sep = ' ';

extension ChatNumberFormat on String {
  /// Returns a readable formatted version of this chat number, for example:
  ///   123467890123     -> 123 468 890 123
  ///   5512346789012355 -> 55 123 468 890 123 55
  String get formattedChatNumber {
    final outsideMatch =
        shortChatNumberRegexOutside.firstMatch(replaceAll(whitespace, ''));
    if (outsideMatch == null) {
      return this;
    }
    final result = StringBuffer();
    result.write(outsideMatch.group(1));
    final inside = outsideMatch.group(2)!;
    final insideMatches = shortChatNumberRegexInside.allMatches(inside);
    if (insideMatches.isEmpty) {
      if (inside.isNotEmpty) {
        if (result.isNotEmpty) result.write(sep);
        result.write(inside);
      }
    } else {
      insideMatches.forEach((insideMatch) {
        if (result.isNotEmpty) result.write(sep);
        result.write(insideMatch.group(1));
        if (insideMatch.group(2) != null) {
          result.write(sep);
          result.write(insideMatch.group(2));
        }
      });
    }
    if (outsideMatch.group(3)!.isNotEmpty) {
      result.write(sep);
      result.write(outsideMatch.group(3));
    }
    return result.toString();
  }

  String get withoutWhitespace => replaceAll(whitespace, '');
}
