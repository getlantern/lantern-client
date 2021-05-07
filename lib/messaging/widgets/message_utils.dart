import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

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
      .forEach((reactorId, reaction) =>
          disposableMap[reactorId] = reaction.emoticon);

  // swap keys-values to create emoticon <--> List<reactorId>
  // TODO: we need to create a String<reactorId> instead of only storing one at a time
  disposableMap
      .forEach((reactorId, reaction) => reactions[reaction] = [reactorId]);

  reactions.forEach((reaction, reactorIdList) =>
      reactions[reaction] = _convertIdToDisplayName(reactorIdList, contact));
  return reactions;
}

List<dynamic> _convertIdToDisplayName(
    List<dynamic> reactorIdList, Contact contact) {
  if (reactorIdList.isEmpty) return [];

  if (reactorIdList.contains(contact.contactId.id)) {
    return [contact.displayName];
  } else {
    // TODO: Add i18next
    return ['me'];
  }
}

IconData? getStatusIcon(bool inbound, StoredMessage msg) {
  inbound
      ? null
      : msg.status == StoredMessage_DeliveryStatus.SENDING
          ? Icons.pending_outlined
          : msg.status == StoredMessage_DeliveryStatus.COMPLETELY_FAILED ||
                  msg.status == StoredMessage_DeliveryStatus.PARTIALLY_FAILED
              ? Icons.error_outline
              : null;
}
