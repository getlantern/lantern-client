import 'package:lantern/common/model.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'contact_list_item.dart';
import '../conversation/message_utils.dart';

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
}) {
  return ScrollablePositionedList.builder(
    itemScrollController: scrollListController,
    initialScrollIndex: initialScrollIndex,
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
                child: Text(key[0].toUpperCase()),
              ),
            ],
          ),
          Divider(height: 1.0, color: grey3),
          if (itemsPerKey.isNotEmpty)
            ...itemsPerKey.map((contact) => ContactListItem(
                  contact: contact.value,
                  index: index,
                  leading: leadingCallback!(contact.value),
                  title: sanitizeContactName(contact.value.displayName),
                  trailing: trailingCallback != null
                      ? trailingCallback(index, contact.value)
                      : null,
                  onTap: onTapCallback != null
                      ? () => onTapCallback(contact.value)
                      : null,
                ))
        ],
      );
    },
  );
}
