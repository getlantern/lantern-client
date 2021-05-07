import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';

Map<String, List<dynamic>> constructReactionsMap(
    StoredMessage msg, Contact contact) {
  var disposableMap = {};
  // hardcode the list of available emoticons in a way that is convenient to parse
  var reactions = {
    '👍': [],
    '👎': [],
    '😄': [],
    '❤': [],
    '😢': [],
  };
  // https://api.dart.dev/stable/2.12.4/dart-core/Map/Map.fromIterables.html
  // create a Map from Iterable<String> and Iterable<Reaction>
  Map.fromIterables(msg.reactions.keys, msg.reactions.values)
      // store reactorID <---> emoticon to disposableMap
      .forEach((key, value) => disposableMap[key] = value.emoticon);

  // swap keys-values to create emoticon <--> List<reactorId>
  // TODO: this eats up any duplicate reactorIds
  disposableMap.forEach((key, value) => reactions[value] = [key]);

  // TODO: match reactorID to DisplayName
  reactions.forEach(
      (key, value) => reactions[key] = convertIdToDisplayName(value, contact));
  return reactions;
}

List<dynamic> convertIdToDisplayName(List<dynamic> value, Contact contact) {
  if (value.isEmpty) return [];

  if (value.contains(contact.contactId.id)) {
    return [contact.displayName];
  } else {
    return ['me'];
  }
}
