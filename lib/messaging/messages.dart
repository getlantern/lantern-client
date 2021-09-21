import 'package:lantern/messaging/introductions/introduction_extension.dart';

import 'messaging.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return model.me((BuildContext context, Contact me, Widget? child) {
      return BaseScreen(
          title: 'messages'.i18n,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'search'.i18n,
              onPressed: () {},
            ),
          ],
          body:
              // TODO: the below is just a temporary hack to make sure people have
              // set their display name. Once we have a proper onboarding flow,
              // we'll use that instead.
              me.displayName.isEmpty
                  ? Align(
                      alignment: Alignment.center,
                      child: Button(
                        width: 200,
                        text: 'Set Display Name'.i18n,
                        onPressed: () {
                          context.pushRoute(DisplayName(me: me));
                        },
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        model.introductionsFromContact(
                            builder: (context,
                                    Iterable<PathAndValue<StoredMessage>>
                                        introductions,
                                    Widget? child) =>
                                (introductions.getPending().isNotEmpty)
                                    ? CListTile(
                                        leading: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  start: 16.0),
                                          child: CBadge(
                                            count: introductions
                                                .getPending()
                                                .length,
                                            showBadge: true,
                                            child: const Icon(
                                              Icons.people,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        content: CText('introductions'.i18n,
                                            style: tsSubtitle1Short),
                                        trailing: const CAssetImage(
                                          path: ImagePaths.keyboard_arrow_right,
                                          size: iconSize,
                                        ),
                                        onTap: () async => await context
                                            .pushRoute(const Introductions()),
                                      )
                                    : const SizedBox()),
                        Expanded(
                          child: model.contactsByActivity(builder: (context,
                              Iterable<PathAndValue<Contact>> _contacts,
                              Widget? child) {
                            var contacts = _contacts
                                .where((contact) =>
                                    contact.value.mostRecentMessageTs > 0)
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
                                          id: contact.value.contactId.id,
                                          displayName:
                                              contact.value.displayName),
                                      title: sanitizeContactName(
                                          contact.value.displayName),
                                      subtitle: CText(
                                          "${contact.value.mostRecentMessageText.isNotEmpty ? contact.value.mostRecentMessageText : 'attachment'.i18n}",
                                          style: tsBody2),
                                      onTap: () async =>
                                          await context.pushRoute(Conversation(
                                              contactId:
                                                  contact.value.contactId)),
                                      trailing: HumanizedDate.fromMillis(
                                        contact.value.mostRecentMessageTs
                                            .toInt(),
                                        builder: (context, date) =>
                                            CText(date, style: tsBody2),
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
          actionButton: me.displayName.isEmpty
              ? null
              : FloatingActionButton(
                  onPressed: () async =>
                      await context.pushRoute(const NewMessage()),
                  child: const Icon(Icons.add),
                ));
    });
  }
}
