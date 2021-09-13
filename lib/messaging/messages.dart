import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/custom_badge.dart';
import 'package:lantern/common/humanized_date.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/contacts/contact_list_item.dart';
import 'package:lantern/messaging/conversation/message_utils.dart';
import 'package:lantern/messaging/introductions/introduction_extension.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
        title: 'messages'.i18n,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'search'.i18n,
            onPressed: () {},
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
                              title: Text('introductions'.i18n,
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
                        ContactListItem(
                          contact: contact.value,
                          index: index,
                          leading: renderContactAvatar(
                              displayName: contact.value.displayName),
                          title: sanitizeContactName(contact.value.displayName),
                          subtitle: Text(
                              "${contact.value.mostRecentMessageText.isNotEmpty ? contact.value.mostRecentMessageText : 'attachment'.i18n}",
                              overflow: TextOverflow.ellipsis),
                          onTap: () async => await context.pushRoute(
                              Conversation(contactId: contact.value.contactId)),
                          trailing: HumanizedDate.fromMillis(
                            contact.value.mostRecentMessageTs.toInt(),
                            builder: (context, date) => Text(date),
                          ),
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
