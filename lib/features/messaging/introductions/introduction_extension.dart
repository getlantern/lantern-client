import 'package:lantern/features/messaging/messaging.dart';

// Filters for items from an Iterable<Introductions> of "Pending" status
extension IntroductionExtension on Iterable<PathAndValue<StoredMessage>> {
  Iterable<PathAndValue<StoredMessage>> getPending() {
    return [...this].toList().where(
          (intro) =>
              intro.value.introduction.isPending() &&
              intro.value.introduction.constrainedVerificationLevel !=
                  VerificationLevel.UNACCEPTED,
        ); // get Pending from accepted contacts
  }
}

extension IntroductionStatus on IntroductionDetails {
  bool isPending() {
    return status == IntroductionDetails_IntroductionStatus.PENDING;
  }

  bool isAccepted() {
    return status == IntroductionDetails_IntroductionStatus.ACCEPTED;
  }
}
