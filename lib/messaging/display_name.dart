import 'messaging.dart';

extension ContactDisplayName on Contact {
  String get displayNameOrFallback {
    if (isMe) {
      return 'me'.i18n;
    }
    if (displayName.isNotEmpty) {
      return displayName;
    }
    if (chatNumber.shortNumber.isNotEmpty) {
      return chatNumber.shortNumber.formattedChatNumber;
    }
    return 'unnamed_contact'.i18n;
  }
}

extension IntroductionDisplayName on IntroductionDetails {
  String get displayNameOrFallback =>
      displayName.isEmpty ? 'unnamed_contact'.i18n : displayName;
}

String humanizeLongString(String id) {
  var humanizedId = id.splitMapJoin(RegExp('.{4}'),
      onMatch: (m) => '${m[0]}', // (or no onMatch at all)
      onNonMatch: (n) => '-');

  return humanizedId.substring(1, humanizedId.length - 1);
}
