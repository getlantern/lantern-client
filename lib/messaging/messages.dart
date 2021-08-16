import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/generic_list_item.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';
import 'package:lantern/utils/humanize.dart';
import 'package:lantern/utils/introduction_extension.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
        title: 'Messages'.i18n,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search'.i18n,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Your Contact Info'.i18n,
            onPressed: () async => await context.pushRoute(
              const ContactInfo(),
            ),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            model.introductionsFromContact(
                builder: (context,
                        Iterable<PathAndValue<StoredMessage>> introductions,
                        Widget? child) =>
                    (introductions.getPending().isNotEmpty)
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: CustomBadge(
                                count: introductions.getPending().length,
                                showBadge: true,
                                child: const Icon(
                                  Icons.people,
                                  color: Colors.black,
                                ),
                              ),
                              title: Text('Introductions'.i18n,
                                  style: tsBaseScreenBodyText),
                              trailing: const CustomAssetImage(
                                path: ImagePaths.keyboard_arrow_right_icon,
                                size: 24,
                              ),
                              onTap: () async => await context
                                  .pushRoute(const Introductions()),
                            ),
                          )
                        : Container()),
            Expanded(
              child: model.contactsByActivity(builder: (context,
                  Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
                var contacts = _contacts
                    .where((contact) => contact.value.mostRecentMessageTs > 0)
                    .toList();
                contacts.sort((a, b) {
                  return (b.value.mostRecentMessageTs -
                          a.value.mostRecentMessageTs)
                      .toInt();
                });
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    // false will style this as a Message preview
                    var contact = contacts[index];
                    return Column(
                      children: [
                        GenericListItem(
                          contact: contact.value,
                          index: index,
                          leading: CircleAvatar(
                            backgroundColor: avatarBgColors[
                                generateUniqueColorIndex(
                                    contact.value.contactId.id)],
                            child: Text(
                                sanitizeContactName(contact.value.displayName)
                                    .substring(0, 2)
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: sanitizeContactName(contact.value.displayName),
                          subtitle: Text(
                              "${contact.value.mostRecentMessageText.isNotEmpty ? contact.value.mostRecentMessageText : 'attachment'.i18n}",
                              overflow: TextOverflow.ellipsis),
                          onTap: () async => await context
                              .pushRoute(Conversation(contact: contact.value)),
                          trailing: Text(contact.value.mostRecentMessageTs
                              .toInt()
                              .humanizeDate()
                              .toString()),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
        actionButton: FloatingActionButton(
          onPressed: () async => await context.pushRoute(const NewMessage()),
          child: const Icon(Icons.add),
        ));
  }
}
