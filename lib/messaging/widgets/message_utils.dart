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
    '😢': [], // TODO: Add the [...] option here
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

Future<void> displayEmojiBreakdownPopup(BuildContext context, StoredMessage msg,
    Map<String, List<dynamic>> reactions) {
  return showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) => Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
              ),
              const Center(
                  child: Text('Reactions', style: TextStyle(fontSize: 18.0))),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var reaction in reactions.entries)
                    if (reaction.value.isNotEmpty)
                      ListTile(
                        leading: Text(reaction.key),
                        title: Text(reaction.value.join(', ')),
                      ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(12),
              ),
            ],
          ));
}

Container displayEmojiCount(
    Map<String, List<dynamic>> reactions, String emoticon) {
  // identify which Map (key-value) pair corresponds to the emoticton at hand
  final currentReactionKey =
      reactions.keys.firstWhere((key) => key == emoticon);
  final reactorsToKey = reactions[currentReactionKey]!;
  return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // TODO generalize in theme
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
          padding: reactorsToKey.length > 1
              ? const EdgeInsets.only(left: 3, top: 3, right: 6, bottom: 3)
              : const EdgeInsets.all(3),
          child: reactorsToKey.length > 1
              ? Text(emoticon + reactorsToKey.length.toString())
              : Text(emoticon)));
}
