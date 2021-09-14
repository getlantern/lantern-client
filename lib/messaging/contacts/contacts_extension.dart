import 'package:lantern/messaging/messaging.dart';

extension ContactExtension on List<PathAndValue<Contact>> {
  List<PathAndValue<Contact>> sortedAlphabetically() {
    return [...this]..sort((a, b) =>
        sanitizeContactName(a.value.displayName.toLowerCase())
            .compareTo(sanitizeContactName(b.value.displayName.toLowerCase())));
  }
}
