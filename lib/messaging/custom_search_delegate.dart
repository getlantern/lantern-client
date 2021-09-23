import 'messaging.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        elevation: 0,
        color: white,
      ),
    );
  }

  @override
  TextStyle get searchFieldStyle => tsSubtitle2.copiedWith(color: grey5);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const CAssetImage(path: ImagePaths.cancel),
        onPressed: () {
          query.isEmpty ? close(context, null) : query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const CAssetImage(path: ImagePaths.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return query.isEmpty
        // TODO: handle on UI
        ? const Center(child: Text('Empty state container'))
        : query.length < 3
            ? Center(child: Text('Please enter at least 3 letters'.i18n))
            : FutureBuilder(
                future: Future.wait(
                    [model.searchContacts(query), model.searchMessages(query)]),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.hasError) {
                        // TODO: handle on UI
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final results = snapshot.data as List;

                        return LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          // scale height to keep line height the same even though font size changed
                          return Container(
                            width: constraints.maxWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 20, top: 20),
                                  child: Text(
                                    'Contacts (${results[0].length} results)'
                                        .i18n
                                        .toUpperCase(),
                                  ),
                                ),
                                Flexible(
                                  child: SuggestedContacts(
                                    contacts: results[0] as List<Contact>,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 20, top: 20),
                                  child: Text(
                                      'Messages (${results[1].length} results)'
                                          .i18n
                                          .toUpperCase()),
                                ),
                                Flexible(
                                  child: SuggestedMessages(
                                    model: model,
                                    messages: results[1] as List<StoredMessage>,
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      }
                  }
                });
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(child: Text('build results'));
  }
}

class SuggestedContacts extends StatelessWidget {
  final List<Contact> contacts;

  const SuggestedContacts({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: contacts.length,
        physics: defaultScrollPhysics,
        itemBuilder: (context, index) {
          var contact = contacts[index];
          return Column(
            children: [
              ContactListItem(
                contact: contact,
                index: index,
                leading: CustomAvatar(
                    id: contact.contactId.id,
                    displayName:
                        contact.displayName.replaceAll(RegExp(r'\*'), '')),
                title: RichText(
                  text: TextSpan(
                    text: contact.displayName.split('*')[0],
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: contact.displayName.split('*')[1],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      TextSpan(text: contact.displayName.split('*')[2]),
                    ],
                  ),
                ),
                onTap: () async => await context
                    .pushRoute(Conversation(contactId: contact.contactId)),
                trailing: null,
                disableBorders: true,
              ),
            ],
          );
        });
    ;
  }
}

class SuggestedMessages extends StatelessWidget {
  final MessagingModel model;
  final List<StoredMessage> messages;

  const SuggestedMessages({required this.model, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: messages.length,
        physics: defaultScrollPhysics,
        itemBuilder: (context, index) {
          var message = messages[index];
          return model.singleContactById(context, message.contactId,
              (context, contact, child) {
            return Column(
              children: [
                ContactListItem(
                  contact: contact,
                  index: index,
                  leading: CustomAvatar(
                      id: message.contactId.id,
                      displayName: contact.displayName),
                  title: CText(
                      sanitizeContactName(contact.displayName).toString(),
                      maxLines: 1,
                      style: tsSubtitle1Short),
                  subtitle: RichText(
                      text: TextSpan(
                    text: message.text.split('*')[0],
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: message.text.split('*')[1],
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      TextSpan(text: message.text.split('*')[2]),
                    ],
                  )),
                  onTap: () async => await context
                      .pushRoute(Conversation(contactId: message.contactId)),
                  trailing: null,
                  disableBorders: true,
                ),
              ],
            );
          });
        });
    ;
  }
}
