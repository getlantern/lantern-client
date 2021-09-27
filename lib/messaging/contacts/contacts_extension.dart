import 'package:lantern/messaging/messaging.dart';

extension ContactExtension on List<PathAndValue<Contact>> {
  List<PathAndValue<Contact>> sortedAlphabetically() {
    return [...this]..sort((a, b) => a.value.displayName
        .toLowerCase()
        .compareTo(b.value.displayName.toLowerCase()));
  }
}
