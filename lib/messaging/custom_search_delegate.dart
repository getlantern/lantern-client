import 'messaging.dart';
import 'package:lantern/common/common.dart';

class CustomSearchDelegate extends SearchDelegate {
  late bool? searchMessages;

  CustomSearchDelegate({this.searchMessages = false});

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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
          padding: const EdgeInsetsDirectional.all(16.0),
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: white,
          child: query.isEmpty || query.length < 3
              ? Center(
                  child: Text(
                  'search_chars_min'.i18n,
                  style: tsSubtitle1,
                  textAlign: TextAlign.center,
                ))
              : FutureBuilder(
                  future: searchMessages!
                      ? Future.wait([
                          model.searchContacts(query),
                          model.searchMessages(query)
                        ])
                      : Future.wait([model.searchContacts(query)]),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError) {
                          showErrorDialog(context,
                              e: snapshot.error!,
                              s: snapshot.stackTrace!,
                              des: 'search_error'.i18n);
                          return Center(
                              child: Text('search_error'.i18n,
                                  style: tsSubtitle1,
                                  textAlign: TextAlign.center));
                        } else {
                          final results = snapshot.data as List;
                          final contacts = results[0] as List<Contact>;
                          final messages = searchMessages!
                              ? results[1] as List<StoredMessage>
                              : [];
                          final hasResults =
                              contacts.isNotEmpty || messages.isNotEmpty;

                          return (hasResults)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          top: 20),
                                      child: Text(
                                        'Contacts (${contacts.length} results)'
                                            .i18n
                                            .toUpperCase(),
                                      ),
                                    ),
                                    SuggestionBuilder(
                                      suggestions: contacts,
                                    ),
                                    if (searchMessages!)
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                top: 20),
                                        child: Text(
                                            'Messages (${messages.length} results)'
                                                .i18n
                                                .toUpperCase()),
                                      ),
                                    if (searchMessages!)
                                      SuggestionBuilder(
                                        model: model,
                                        suggestions: messages,
                                      ),
                                  ],
                                )
                              : Center(
                                  child: Text('search_no_results'.i18n,
                                      style: tsSubtitle1,
                                      textAlign: TextAlign.center));
                        }
                    }
                  }));
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }
}

class SuggestionBuilder extends StatelessWidget {
  final MessagingModel? model;
  final List suggestions;
  const SuggestionBuilder({this.model, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: suggestions.isNotEmpty ? 1 : 0,
      child: ListView.builder(
          itemCount: suggestions.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: defaultScrollPhysics,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemBuilder: (context, index) {
            var suggestion = suggestions[index];

            if (suggestion is Contact) {
              return ContactListItem(
                contact: suggestion,
                index: index,
                leading: CustomAvatar(
                    id: suggestion.contactId.id,
                    displayName:
                        suggestion.displayName.replaceAll(RegExp(r'\*'), '')),
                title: suggestion.displayName,
                onTap: () async => await context
                    .pushRoute(Conversation(contactId: suggestion.contactId)),
                showDivider: false,
                useMarkdown: true,
              );
            }
            if (suggestion is StoredMessage) {
              return model!.singleContactById(context, suggestion.contactId,
                  (context, contact, child) {
                return ContactListItem(
                  contact: contact,
                  index: index,
                  leading: CustomAvatar(
                      id: suggestion.contactId.id,
                      displayName: contact.displayName),
                  title: sanitizeContactName(contact.displayName).toString(),
                  subTitle: suggestion.text,
                  // TODO: scroll to message
                  onTap: () async => await context
                      .pushRoute(Conversation(contactId: suggestion.contactId)),
                  showDivider: false,
                  useMarkdown: true,
                );
              });
            }
            return Container();
          }),
    );
  }
}
