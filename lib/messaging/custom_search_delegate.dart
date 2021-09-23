import 'package:flutter_markdown/flutter_markdown.dart';

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
    // TODO: dismiss keyboard on scroll
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
          padding: const EdgeInsetsDirectional.all(16.0),
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: white,
          child: query.isEmpty
              // TODO: update copy
              ? const Center(child: Text('Empty state container'))
              : query.length < 3
                  // TODO: update copy
                  ? Center(child: Text('Please enter at least 3 letters'.i18n))
                  : FutureBuilder(
                      future: Future.wait([
                        model.searchContacts(query),
                        model.searchMessages(query)
                      ]),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const Center(
                                child: CircularProgressIndicator());
                          default:
                            if (snapshot.hasError) {
                              // TODO: handle on UI?
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else {
                              final results = snapshot.data as List;
                              final contacts = results[0] as List<Contact>;
                              final messages =
                                  results[1] as List<StoredMessage>;

                              return (contacts.isNotEmpty ||
                                      messages.isNotEmpty)
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  start: 20, top: 20),
                                          child: Text(
                                            'Contacts (${contacts.length} results)'
                                                .i18n
                                                .toUpperCase(),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: SuggestedContacts(
                                            contacts: contacts,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  start: 20, top: 20),
                                          child: Text(
                                              'Messages (${messages.length} results)'
                                                  .i18n
                                                  .toUpperCase()),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: SuggestedMessages(
                                            model: model,
                                            messages: messages,
                                          ),
                                        ),
                                      ],
                                    )
                                  // TODO: update copy
                                  : const Center(
                                      child: Text('No results found sorrrry'));
                            }
                        }
                      }));
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: can we just do that? Need to look this up
    return buildSuggestions(context);
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
                title: MarkdownBody(
                  data: contact.displayName,
                  styleSheet: MarkdownStyleSheet(
                    p: tsSubtitle1Short,
                    em: tsSubtitle1Short.copiedWith(
                        color: pink4, fontWeight: FontWeight.w500),
                  ),
                ),
                onTap: () async => await context
                    .pushRoute(Conversation(contactId: contact.contactId)),
                trailing: null,
                showDivider: false,
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
                  subtitle: MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet(
                      p: tsBody2,
                      em: tsBody2.copiedWith(
                          color: pink4, fontWeight: FontWeight.w500),
                    ),
                  ),
                  // TODO: scroll to message
                  onTap: () async => await context
                      .pushRoute(Conversation(contactId: message.contactId)),
                  trailing: null,
                  showDivider: false,
                ),
              ],
            );
          });
        });
  }
}
