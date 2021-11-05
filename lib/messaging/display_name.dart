import 'messaging.dart';

extension ContactDisplayName on Contact {
  String get displayNameOrFallback => isMe
      ? 'me'.i18n
      : displayName.isEmpty
          ? 'unnamed_contact'.i18n
          : displayName;
}

extension IntroductionDisplayName on IntroductionDetails {
  String get displayNameOrFallback =>
      displayName.isEmpty ? 'unnamed_contact'.i18n : displayName;
}

extension HumanizedContactId on Contact {
  String humanizeContactId(String id) {
    var humanizedId = id.splitMapJoin(RegExp('.{4}'),
        onMatch: (m) => '${m[0]}', // (or no onMatch at all)
        onNonMatch: (n) => '-');

    return humanizedId.substring(1, humanizedId.length - 1);
  }
}
