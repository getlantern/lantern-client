import 'package:lantern/messaging/messaging.dart';

// Filters for items from an Iterable<Introductions> of "Pending" status
extension IntroductionExtension on Iterable<PathAndValue<StoredMessage>> {
  Iterable<PathAndValue<StoredMessage>> getPending() {
    return [...this].toList().where((intro) =>
        intro.value.introduction.status ==
        IntroductionDetails_IntroductionStatus.PENDING);
  }
}
