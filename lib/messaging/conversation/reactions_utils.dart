import 'package:lantern/common/common.dart';

import '../messaging.dart';

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
                title: CText('Reactions'.i18n, maxLines: 1, style: tsSubtitle1),
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
