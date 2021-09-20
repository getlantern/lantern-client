import 'package:lantern/common/common.dart';

import '../messaging.dart';

Map<String, List<dynamic>> constructReactionsMap(
    StoredMessage msg, Contact contact) {
  // hardcode the list of available emoticons in a way that is convenient to parse
  var reactions = {'👍': [], '👎': [], '😄': [], '❤': [], '😢': [], '•••': []};
  // https://api.dart.dev/stable/2.12.4/dart-core/Map/Map.fromIterables.html
  // create a Map from Iterable<String> and Iterable<Reaction>
  var reactor_emoticon_map = {};
  Map.fromIterables(msg.reactions.keys, msg.reactions.values)
      // reactorID <---> emoticon to reactor_emoticon_map
      .forEach((reactorId, reaction) =>
          reactor_emoticon_map[reactorId] = reaction.emoticon);

  // swap key-value pairs to create emoticon <--> List<reactorId>
  reactor_emoticon_map.forEach((reactorId, reaction) {
    reactions[reaction] = [...?reactions[reaction], reactorId];
  });

  // humanize reactorIdList
  reactions.forEach((reaction, reactorIdList) =>
      reactions[reaction] = _humanizeReactorIdList(reactorIdList, contact));

  return reactions;
}

List<dynamic> _humanizeReactorIdList(
    List<dynamic> reactorIdList, Contact contact) {
  var humanizedList = [];
  if (reactorIdList.isEmpty) return humanizedList;

  reactorIdList.forEach((reactorId) =>
      humanizedList.add(_matchIdToDisplayName(reactorId, contact)));
  return humanizedList;
}

String _matchIdToDisplayName(String contactIdToMatch, Contact contact) {
  return contactIdToMatch == contact.contactId.id
      ? contact.displayName
      : 'me'.i18n;
}

List<dynamic> constructReactionsList(BuildContext context,
    Map<String, List<dynamic>> reactions, StoredMessage msg) {
  var reactionsList = [];
  reactions.forEach(
    (key, value) {
      if (value.isNotEmpty) {
        reactionsList.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            // Tap on emoji to bring modal with breakdown of interactions
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => showBottomModal(
                context: context,
                title: TextOneLine('Reactions'.i18n, style: tsSubtitle1),
                children: [
                  for (var reaction in reactions.entries)
                    if (reaction.value.isNotEmpty)
                      BottomModalItem(
                        leading: CText(reaction.key, style: tsBody1),
                        label: reaction.value.join(', '),
                      ),
                ],
              ),
              child: _displayEmojiCount(reactions, key),
            ),
          ),
        );
      }
    },
  );
  return reactionsList;
}

Container _displayEmojiCount(
    Map<String, List<dynamic>> reactions, String emoticon) {
  // identify which Map (key-value) pair corresponds to the displayed emoticon
  final reactionKey = reactions.keys.firstWhere((key) => key == emoticon);
  final reactorsToKey = reactions[reactionKey]!;
  return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
          padding: reactorsToKey.length > 1
              ? const EdgeInsets.only(left: 3, top: 3, right: 6, bottom: 3)
              : const EdgeInsets.all(3),
          child: reactorsToKey.length > 1
              ? CText(emoticon + reactorsToKey.length.toString(),
                  style: CTextStyle(fontSize: 12, lineHeight: 16))
              : CText(emoticon,
                  style: CTextStyle(fontSize: 12, lineHeight: 16))));
}
