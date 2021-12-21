final shortChatNumberRegexOutside = RegExp(r'^(5*)([0-9]*)(5*)$');
final shortChatNumberRegexInside = RegExp(r'([0-9]{3})([0-9]{1,2}$)?');
final fullRecoveryKeyRegex = RegExp(r'^([a-zA-Z0-9]{4})*([a-zA-Z0-9]{1,3}$)?$');
final recoveryKeyRegex = RegExp(r'([a-zA-Z0-9]{4})([a-zA-Z0-9]{1,3}$)?');
final whitespace = RegExp(r'\s');
final nonNumeric = RegExp(r'[^0-9]');
final sep = ' ';

extension NumberAndKeyFormat on String {
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

  /// Returns a readable formatted version of this recovery key, for example:
  ///   abcd1234efgh7890ij -> abcd 1234 efgh 7890 ij
  String get formattedRecoveryKey {
    final unformatted = withoutWhitespace;
    if (fullRecoveryKeyRegex.stringMatch(unformatted) == null) {
      return unformatted;
    }

    final matches = recoveryKeyRegex.allMatches(unformatted);
    if (matches.isEmpty) {
      return unformatted;
    }

    final result = StringBuffer();
    matches.forEach((insideMatch) {
      if (result.isNotEmpty) result.write(sep);
      result.write(insideMatch.group(1));
      if (insideMatch.group(2) != null) {
        result.write(sep);
        result.write(insideMatch.group(2));
      }
    });
    return result.toString();
  }

  String get withoutWhitespace => replaceAll(whitespace, '');

  String get numbersOnly => replaceAll(nonNumeric, '');

  String get spaced {
    final spaced = splitMapJoin(
      RegExp('.{4}'),
      onMatch: (m) => '${m[0]}', // (or no onMatch at all)
      onNonMatch: (n) => ' ',
    ); // uses a non-breaking hyphen

    return spaced.substring(1, spaced.length - 1);
  }
}
