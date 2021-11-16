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
