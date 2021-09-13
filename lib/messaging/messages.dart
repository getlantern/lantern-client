import 'package:auto_route/auto_route.dart';
import 'package:lantern/common/model.dart';
import 'package:lantern/common/ui/button.dart';
import 'package:lantern/common/ui/custom_badge.dart';
import 'package:lantern/common/ui/humanized_date.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/contacts/contact_list_item.dart';
import 'package:lantern/messaging/conversation/message_utils.dart';
import 'package:lantern/messaging/introductions/introduction_extension.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';
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
        body: model.me((BuildContext context, Contact me, Widget? child) {
          // TODO: the below is just a temporary hack to make sure people have
          // set their display name. Once we have a proper onboarding flow,
          // we'll use that instead.
          if (me.displayName.isEmpty) {
            return Align(
              alignment: Alignment.center,
              child: Button(
                width: 200,
                text: 'Set Display Name'.i18n,
                onPressed: () {
                  context.pushRoute(DisplayName(me: me));
                },
              ),
            );
          }
          return Column(
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
                            title:
                                sanitizeContactName(contact.value.displayName),
                            subtitle: Text(
                                "${contact.value.mostRecentMessageText.isNotEmpty ? contact.value.mostRecentMessageText : 'attachment'.i18n}",
                                overflow: TextOverflow.ellipsis),
                            onTap: () async => await context.pushRoute(
                                Conversation(
                                    contactId: contact.value.contactId)),
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
          );
        }),
        actionButton: FloatingActionButton(
          onPressed: () async => await context.pushRoute(const NewMessage()),
          child: const Icon(Icons.add),
        ));
  }
}
