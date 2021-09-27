import 'package:lantern/common/common.dart';

import 'messaging.dart';

class CustomSearchDelegate extends SearchDelegate {
  late bool? searchMessages;

  CustomSearchDelegate({this.searchMessages = false});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        elevation: 1,
        color: white,
      ),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
    );
  }

  @override
  TextStyle get searchFieldStyle => tsSubtitle2.copiedWith(color: grey5);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: CAssetImage(
            path: ImagePaths.cancel,
            color: query.isNotEmpty ? black : transparent),
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
              // TODO (maybe) - consider ValueListenableBuilder when/if we display thumbnails
              : FutureBuilder(
                  future: Future.wait([
                    model.searchContacts(query, 10),
                    if (searchMessages == true) model.searchMessages(query, 10)
                  ]),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      default:
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('search_error'.i18n,
                                  style: tsSubtitle1,
                                  textAlign: TextAlign.center));
                        } else {
                          final results = snapshot.data as List;
                          final contacts =
                              results[0] as List<SearchResult<Contact>>;
                          final messages = searchMessages!
                              ? results[1] as List<SearchResult<StoredMessage>>
                              : [];
                          final hasResults =
                              contacts.isNotEmpty || messages.isNotEmpty;

                          return (hasResults)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    if (contacts.isNotEmpty)
                                      Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  top: 20),
                                          child: Text('search_contacts'
                                              .i18n
                                              .fill([
                                            contacts.length
                                          ]).toUpperCase())),
                                    if (contacts.isNotEmpty)
                                      SuggestionBuilder(
                                        suggestions: contacts,
                                      ),
                                    if (searchMessages! && messages.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                top: 20),
                                        child: Text('search_messages'.i18n.fill(
                                            [messages.length]).toUpperCase()),
                                      ),
                                    if (searchMessages! && messages.isNotEmpty)
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
      flex: 0,
      child: ListView.builder(
          itemCount: suggestions.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: defaultScrollPhysics,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemBuilder: (context, index) {
            var suggestion = suggestions[index];

            if (suggestion is SearchResult<Contact>) {
              return ContactListItem(
                contact: suggestion.value,
                index: index,
                leading: CustomAvatar(
                    id: suggestion.value.contactId.id,
                    displayName: suggestion.value.displayName),
                title: suggestion.snippet,
                onTap: () async => await context.pushRoute(
                    Conversation(contactId: suggestion.value.contactId)),
                showDivider: false,
                useMarkdown: true,
              );
            }
            if (suggestion is SearchResult<StoredMessage>) {
              return model!
                  .singleContactById(context, suggestion.value.contactId,
                      (context, contact, child) {
                return model!.contactMessages(contact, builder: (context,
                    Iterable<PathAndValue<StoredMessage>> messageRecords,
                    Widget? child) {
                  final initialScrollIndex = messageRecords.toList().indexWhere(
                      (element) => element.value.id == suggestion.value.id);
                  return ContactListItem(
                    contact: contact,
                    index: index,
                    leading: CustomAvatar(
                        id: suggestion.value.contactId.id,
                        displayName: contact.displayName),
                    title: contact.displayName.toString(),
                    subTitle: suggestion.snippet,
                    onTap: () async => await context.pushRoute(Conversation(
                        contactId: suggestion.value.contactId,
                        initialScrollIndex: initialScrollIndex)),
                    showDivider: false,
                    useMarkdown: true,
                  );
                });
              });
            }
            return Container();
          }),
    );
  }
}
