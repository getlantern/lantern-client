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
          Row(
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0, 4.0),
                child: CText(key[0].toUpperCase(), style: tsOverline),
              ),
            ],
          ),
          const CDivider(),
          if (itemsPerKey.isNotEmpty)
            ...itemsPerKey.map((contact) => FocusedMenuHolder(
                  menu: (focusMenuCallback != null)
                      ? focusMenuCallback(contact.value)
                      : const SizedBox(),
                  onOpen: () {}, // TODO: maybe needed for keyboard dismissal
                  menuWidth: MediaQuery.of(context).size.width * 0.8,
                  child: ContactListItem(
                    contact: contact.value,
                    index: index,
                    leading: leadingCallback!(contact.value),
                    title: contact.value.displayNameOrFallback,
                    trailing: trailingCallback != null
                        ? trailingCallback(index, contact.value)
                        : null,
                    onTap: onTapCallback != null
                        ? () => onTapCallback(contact.value)
                        : null,
                  ),
                ))
        ],
      );
    },
  );
}
