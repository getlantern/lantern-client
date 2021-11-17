import 'package:lantern/messaging/contacts/grouped_contact_list.dart';
import 'package:lantern/messaging/contacts/contacts_extension.dart';
import 'package:lantern/messaging/messaging.dart';

class Introduce extends StatefulWidget {
  @override
  _IntroduceState createState() => _IntroduceState();
}

class _IntroduceState extends State<Introduce> {
  List<String> selectedContactIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
        title: 'introduce_contacts_with_count'
            .i18n
            .fill([selectedContactIds.length]),
        body: model.contacts(builder: (context,
            Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
          var sortedContacts = _contacts
              .where((element) =>
                  element.value.isAccepted() && element.value.isNotBlocked())
              .toList()
              .sortedAlphabetically();

          var groupedSortedContacts = sortedContacts
              .groupBy((el) => el.value.displayNameOrFallback[0].toLowerCase());

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sortedContacts.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child:
                        CText('introduce_contacts_select'.i18n, style: tsBody1),
                  ),
                Expanded(
                    child: (sortedContacts.length <= 1)
                        ? Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CAssetImage(
                                path: ImagePaths.empty_search,
                                size: 130,
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.all(24.0),
                                child: CText(
                                    'need_two_contacts_to_introduce'.i18n,
                                    style: tsSubtitle1,
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Expanded(
                                  flex: 2,
                                  child: groupedContactListGenerator(
                                      groupedSortedList: groupedSortedContacts,
                                      leadingCallback: (Contact contact) =>
                                          CustomAvatar(
                                              messengerId: contact.contactId.id,
                                              displayName: contact
                                                  .displayNameOrFallback),
                                      trailingCallback: (int index,
                                              Contact contact) =>
                                          Checkbox(
                                            checkColor: Colors.white,
                                            fillColor: MaterialStateProperty
                                                .resolveWith((states) =>
                                                    getCheckboxFillColor(
                                                        black, states)),
                                            value: selectedContactIds
                                                .contains(contact.contactId.id),
                                            shape: const CircleBorder(
                                                side: BorderSide.none),
                                            onChanged: (bool? value) =>
                                                setState(() {
                                              value!
                                                  ? selectedContactIds
                                                      .add(contact.contactId.id)
                                                  : selectedContactIds.remove(
                                                      contact.contactId.id);
                                            }),
                                          )),
                                ),
                                (selectedContactIds.length >= 2)
                                    ? Container(
                                        color: white,
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Button(
                                                width: 200,
                                                text: 'send_introductions'
                                                    .i18n
                                                    .toUpperCase(),
                                                onPressed: () async {
                                                  await model.introduce(
                                                      selectedContactIds);
                                                  showSnackbar(
                                                    context: context,
                                                    content:
                                                        'introductions_sent'
                                                            .i18n,
                                                  );
                                                  await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 1000),
                                                    () async => await context
                                                        .router
                                                        .pop(),
                                                  );
                                                },
                                              ),
                                            ]),
                                      )
                                    : Container()
                              ]))
              ]);
        }));
  }
}
