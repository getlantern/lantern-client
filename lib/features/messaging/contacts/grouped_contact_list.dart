import 'package:lantern/features/messaging/messaging.dart';

/*
Renders an alphabetically grouped sorted list of contacts/conversations
*/
ScrollablePositionedList groupedContactListGenerator({
  Map<String, List<PathAndValue<Contact>>>? groupedSortedList,
  ItemScrollController? scrollListController,
  int initialScrollIndex = 0,
  Function? leadingCallback,
  Function? trailingCallback,
  Function? onTapCallback,
  Function? focusMenuCallback,
  List<Widget>? headItems,
  bool? disableSplash = false,
}) {
  final numHeadItems = headItems?.length ?? 0;
  return ScrollablePositionedList.builder(
    itemScrollController: scrollListController,
    initialScrollIndex: initialScrollIndex,
    physics: defaultScrollPhysics,
    itemCount: groupedSortedList!.length + numHeadItems,
    itemBuilder: (context, index) {
      if (index < numHeadItems) {
        return headItems![index];
      }
      index -= numHeadItems;
      var key = groupedSortedList.keys.elementAt(index);
      var itemsPerKey = groupedSortedList.values.elementAt(index);
      return ListBody(
        key: const ValueKey('grouped_contact_list'),
        children: [
          if (itemsPerKey.isNotEmpty)
            ...itemsPerKey.map(
              (contact) => ListItemFactory.messagingItem(
                header: itemsPerKey.indexOf(contact) == 0
                    ? key[0].toUpperCase()
                    : null,
                disableSplash: disableSplash,
                focusedMenu: (focusMenuCallback != null)
                    ? focusMenuCallback(contact.value)
                    : const SizedBox(),
                leading: leadingCallback!(contact.value),
                content: contact.value.displayNameOrFallback,
                subtitle:
                    contact.value.chatNumber.shortNumber.formattedChatNumber,
                trailingArray: trailingCallback != null
                    ? [trailingCallback(index, contact.value)]
                    : [],
                onTap: onTapCallback != null
                    ? () => onTapCallback(contact.value)
                    : null,
              ),
            )
        ],
      );
    },
  );
}
