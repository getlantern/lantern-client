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
                future: model.searchContacts(query),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.hasError) {
                        // TODO: handle on UI
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return SuggestedContactList(
                          suggestedContacts: snapshot.data as List<Contact>,
                        );
                      }
                  }
                });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }
}

class SuggestedContactList extends StatelessWidget {
  final List<Contact>? suggestedContacts;

  const SuggestedContactList({this.suggestedContacts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: suggestedContacts!.length,
        physics: defaultScrollPhysics,
        itemBuilder: (context, index) {
          var contact = suggestedContacts![index];
          return Column(
            children: [
              ContactListItem(
                contact: contact,
                index: index,
                leading: CustomAvatar(
                    id: contact.contactId.id, displayName: contact.displayName),
                title: sanitizeContactName(contact.displayName),
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
