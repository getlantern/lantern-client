import 'package:lantern/messaging/introductions/introduction_extension.dart';
import 'contacts/long_tap_menu.dart';
import 'messaging.dart';

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
        title: 'chats'.i18n,
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
                        ? ListItemFactory.isMessagingItem(
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
                            trailingArray: [
                              const CAssetImage(
                                path: ImagePaths.keyboard_arrow_right,
                                size: iconSize,
                              )
                            ],
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
                if (contacts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 8.0, end: 8.0, top: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: const CAssetImage(
                              path: ImagePaths.placeholder, size: 300),
                        ),
                        CText(
                            'You don’t have any contacts yet. Share your chat number or add a contact here!'
                                .i18n,
                            style: tsBody1Color(grey5)),
                        Expanded(
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              constraints: const BoxConstraints.expand(),
                              child: CustomPaint(
                                painter:
                                    ArrowPainter(), // TODO: definitely need to fine-tune this in a responsive way once the illustration is ready
                              )),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: contacts.length,
                  physics: defaultScrollPhysics,
                  itemBuilder: (context, index) {
                    var contact = contacts[index];
                    return Column(
                      children: [
                        ListItemFactory.isMessagingItem(
                          focusedMenu: renderLongTapMenu(
                              contact: contact.value, context: context),
                          leading: CustomAvatar(
                              messengerId: contact.value.contactId.id,
                              displayName: contact.value.displayNameOrFallback),
                          content:
                              contact.value.displayNameOrFallback.toString(),
                          subtitle:
                              '${contact.value.mostRecentMessageText.isNotEmpty ? contact.value.mostRecentMessageText : 'attachment'}'
                                  .i18n,
                          onTap: () async => await context.pushRoute(
                              Conversation(contactId: contact.value.contactId)),
                          trailingArray: [
                            HumanizedDate.fromMillis(
                              contact.value.mostRecentMessageTs.toInt(),
                              builder: (context, date) => CText(date,
                                  style: tsBody2.copiedWith(color: grey5)),
                            )
                          ],
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
          backgroundColor: blue4,
          onPressed: () async => await context.pushRoute(const NewChat()),
          child: CAssetImage(path: ImagePaths.add, color: white),
        ));
  }
}
