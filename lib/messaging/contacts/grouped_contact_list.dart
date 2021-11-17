import 'package:lantern/messaging/messaging.dart';

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
}) {
  return ScrollablePositionedList.builder(
    itemScrollController: scrollListController,
    initialScrollIndex: initialScrollIndex,
    physics: defaultScrollPhysics,
    itemCount: groupedSortedList!.length,
    itemBuilder: (context, index) {
      var key = groupedSortedList.keys.elementAt(index);
      var itemsPerKey = groupedSortedList.values.elementAt(index);
      return ListBody(
        children: [
          if (itemsPerKey.isNotEmpty)
            ...itemsPerKey.map(
              (contact) => ListItemFactory.messagingItem(
                header: itemsPerKey.indexOf(contact) == 0
                    ? key[0].toUpperCase()
                    : null,
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
