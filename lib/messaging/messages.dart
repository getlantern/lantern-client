import 'package:lantern/messaging/introductions/introduction_extension.dart';
import 'messaging.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
        title: 'messages'.i18n,
        actions: [
          RoundButton(
            onPressed: () async => await showSearch(
              context: context,
              query: '',
              delegate: CustomSearchDelegate(searchMessages: true),
            ),
            backgroundColor: transparent,
            icon: const CAssetImage(path: ImagePaths.search),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            model.bestIntroductions(
                builder: (context,
                        Iterable<PathAndValue<StoredMessage>> introductions,
                        Widget? child) =>
                    (introductions.getPending().isNotEmpty)
                        ? CListTile(
                            leading: CBadge(
                              count: introductions.getPending().length,
                              showBadge: true,
                              child: const Icon(
                                Icons.people,
                                color: Colors.black,
                              ),
                            ),
                            content: CText('introductions'.i18n,
                                style: tsSubtitle1Short),
                            trailing: const CAssetImage(
                              path: ImagePaths.keyboard_arrow_right,
                              size: iconSize,
                            ),
                            onTap: () async =>
                                await context.pushRoute(const Introductions()),
                          )
                        : const SizedBox()),
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
                  physics: defaultScrollPhysics,
                  itemBuilder: (context, index) {
                    var contact = contacts[index];
                    return Column(
                      children: [
                        ContactListItem(
                          contact: contact.value,
                          index: index,
                          leading: CustomAvatar(
                              messengerId: contact.value.contactId.id,
                              displayName: contact.value.displayNameOrFallback),
                          title: contact.value.displayNameOrFallback,
                          subTitle:
                              '${contact.value.mostRecentMessageText.isNotEmpty ? contact.value.mostRecentMessageText : 'attachment'}'
                                  .i18n,
                          onTap: () async => await context.pushRoute(
                              Conversation(contactId: contact.value.contactId)),
                          trailing: HumanizedDate.fromMillis(
                            contact.value.mostRecentMessageTs.toInt(),
                            builder: (context, date) => CText(date,
                                style: tsBody2.copiedWith(color: grey5)),
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
          backgroundColor: pink4,
          onPressed: () async => await context.pushRoute(const NewMessage()),
          child: CAssetImage(path: ImagePaths.add, color: white),
        ));
  }
}
