import 'messaging.dart';

class CustomSearchDelegate extends SearchDelegate {
  late bool? searchMessages;

  CustomSearchDelegate({this.searchMessages = false});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        elevation: 1,
        shadowColor: grey3,
        color: white,
      ),
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
    );
  }

  @override
  String get searchFieldLabel =>
      'search_in_${searchMessages! ? 'chats' : 'contacts'}'.i18n;

  @override
  TextStyle get searchFieldStyle => tsSubtitle2.copiedWith(color: grey5);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: CAssetImage(
          path: ImagePaths.cancel,
          color: query.isNotEmpty ? black : transparent,
        ),
        onPressed: () {
          query.isEmpty ? close(context, null) : query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: mirrorLTR(
        context: context,
        child: const CAssetImage(path: ImagePaths.arrow_back),
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final scrollController = ScrollController();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scrollbar(
          controller: ScrollController(),
          interactive: true,
          // TODO: this generates an annoying error https://github.com/flutter/flutter/issues/97873
          // thumbVisibility: true,
          trackVisibility: true,
          radius: const Radius.circular(scrollBarRadius),
          child: Container(
            padding: const EdgeInsetsDirectional.all(16.0),
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: white,
            child: query.isEmpty || query.length < 3
                ? Center(
                    child: CText(
                      'search_chars_min'.i18n,
                      style: tsSubtitle1,
                      textAlign: TextAlign.center,
                    ),
                  )
                // TODO (maybe) - consider ValueListenableBuilder when/if we display thumbnails
                : FutureBuilder(
                    future: Future.wait([
                      messagingModel.searchContacts(query, 10),
                      if (searchMessages == true)
                        messagingModel.searchMessages(query, 64)
                    ]),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        default:
                          if (snapshot.hasError) {
                            return Center(
                              child: CText(
                                'search_error'.i18n,
                                style: tsSubtitle1,
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            final results = snapshot.data as List;
                            final contacts =
                                results[0] as List<SearchResult<Contact>>;
                            final messages = searchMessages!
                                ? results[1]
                                    as List<SearchResult<StoredMessage>>
                                : [];
                            final hasResults =
                                contacts.isNotEmpty || messages.isNotEmpty;

                            return (hasResults)
                                ? SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        if (contacts.isNotEmpty)
                                          CText(
                                            'search_contacts'.i18n.fill([
                                              contacts.length
                                            ]).toUpperCase(),
                                            style: tsSubtitle1,
                                          ),
                                        if (contacts.isNotEmpty)
                                          SuggestionBuilder(
                                            suggestions: contacts,
                                            scrollController: scrollController,
                                          ),
                                        if (searchMessages! &&
                                            messages.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(top: 10),
                                            child: CText(
                                              'search_chats'.i18n.fill([
                                                messages.length
                                              ]).toUpperCase(),
                                              style: tsOverline,
                                            ),
                                          ),
                                        if (searchMessages! &&
                                            messages.isNotEmpty)
                                          SuggestionBuilder(
                                            model: messagingModel,
                                            suggestions: messages,
                                            scrollController: scrollController,
                                          ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const CAssetImage(
                                          path: ImagePaths.empty_search,
                                          size: 130,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.all(
                                            24.0,
                                          ),
                                          child: CText(
                                            'search_no_results'.i18n,
                                            style: tsSubtitle1,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                          }
                      }
                    },
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }
}

class SuggestionBuilder extends StatelessWidget {
  final MessagingModel? model;
  final List suggestions;
  final ScrollController scrollController;

  const SuggestionBuilder({
    this.model,
    required this.suggestions,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: suggestions.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: defaultScrollPhysics,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (context, index) {
        var suggestion = suggestions[index];

        if (suggestion is SearchResult<Contact>) {
          return ListItemFactory.messagingItem(
            leading: CustomAvatar(
              messengerId: suggestion.value.contactId.id,
              displayName: suggestion.value.displayName,
            ),
            content: suggestion.snippet,
            onTap: () async => await context.pushRoute(
              Conversation(contactId: suggestion.value.contactId),
            ),
            showDivider: false,
            enableHighlighting: true,
          );
        }
        if (suggestion is SearchResult<StoredMessage>) {
          return model!.singleContactById(suggestion.value.contactId,
              (context, contact, child) {
            return model!.contactMessages(
              contact,
              builder: (
                context,
                Iterable<PathAndValue<StoredMessage>> messageRecords,
                Widget? child,
              ) {
                final initialScrollIndex = messageRecords.toList().indexWhere(
                      (element) => element.value.id == suggestion.value.id,
                    );
                return ListItemFactory.messagingItem(
                  leading: CustomAvatar(
                    messengerId: suggestion.value.contactId.id,
                    displayName: contact.displayName,
                  ),
                  content: contact.displayNameOrFallback,
                  subtitle: suggestion.snippet,
                  onTap: () async => await context.pushRoute(
                    Conversation(
                      contactId: suggestion.value.contactId,
                      initialScrollIndex: initialScrollIndex,
                    ),
                  ),
                  showDivider: false,
                  enableHighlighting: true,
                );
              },
            );
          });
        }
        assert(
          false,
          'suggestion type is not supported by Search:  ${suggestion.runtimeType}',
        );
        return const SizedBox();
      },
    );
  }
}
