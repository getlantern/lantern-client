import 'messaging.dart';

extension ContactDisplayName on Contact {
  String get displayNameOrFallback =>
      displayName.isEmpty ? 'unnamed_contact'.i18n : displayName;
}

extension IntroductionDisplayName on IntroductionDetails {
  String get displayNameOrFallback =>
      displayName.isEmpty ? 'unnamed_contact'.i18n : displayName;
}
