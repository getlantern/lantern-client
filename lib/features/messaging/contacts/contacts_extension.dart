import 'package:lantern/features/messaging/messaging.dart';

extension ContactExtension on List<PathAndValue<Contact>> {
  List<PathAndValue<Contact>> sortedAlphabetically() {
    return [...this]..sort(
        (a, b) => a.value.displayNameOrFallback
            .toLowerCase()
            .compareTo(b.value.displayNameOrFallback.toLowerCase()),
      );
  }
}

extension VerificationExtension on Contact {
  bool isUnaccepted() {
    return verificationLevel == VerificationLevel.UNACCEPTED;
  }

  bool isAccepted() {
    return !isUnaccepted();
  }

  bool isUnverified() {
    return verificationLevel == VerificationLevel.UNVERIFIED;
  }

  bool isVerified() {
    return verificationLevel == VerificationLevel.VERIFIED;
  }

  // helps in verbocity for complex conditionals
  bool isNotBlocked() {
    return blocked == false;
  }
}
