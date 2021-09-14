import 'messaging.dart';

String sanitizeContactName(String displayName) {
  return displayName.isEmpty ? 'unnamed_contact'.i18n : displayName.toString();
}

String manuallyHandleOverflow(String name) {
  return name.length > 25 ? '${name.substring(0, 25)}...' : name;
}

String humanizeContactId(String id) {
  var humanizedId = id.splitMapJoin(RegExp('.{4}'),
      onMatch: (m) => '${m[0]}', // (or no onMatch at all)
      onNonMatch: (n) => '-');

  return humanizedId.substring(1, humanizedId.length - 1);
}
