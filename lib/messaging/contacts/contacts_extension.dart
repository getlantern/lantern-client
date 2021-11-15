import 'package:lantern/messaging/messaging.dart';

extension ContactExtension on List<PathAndValue<Contact>> {
  List<PathAndValue<Contact>> sortedAlphabetically() {
    return [...this]..sort((a, b) => a.value.displayNameOrFallback
        .toLowerCase()
        .compareTo(b.value.displayNameOrFallback.toLowerCase()));
  }
}

extension VerificationExtension on Contact {
  bool isUnaccepted() {
    return this.verificationLevel == VerificationLevel.UNACCEPTED;
  }

  bool isUnverified() {
    return this.verificationLevel == VerificationLevel.UNVERIFIED;
  }

  bool isVerified() {
    return this.verificationLevel == VerificationLevel.VERIFIED;
  }
}
