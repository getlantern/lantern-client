import 'messaging.dart';

// TODO: do we need this anymore?
String sanitizeContactName(String displayName) {
  return displayName.isEmpty ? 'unnamed_contact'.i18n : displayName.toString();
}

// splits the contactId into more human readable groups of 4 chars
String humanizeContactId(String id) {
  var humanizedId = id.splitMapJoin(RegExp('.{4}'),
      onMatch: (m) => '${m[0]}', // (or no onMatch at all)
      onNonMatch: (n) => '-');

  return humanizedId.substring(1, humanizedId.length - 1);
}
