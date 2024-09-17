import 'package:lantern/messaging/contacts/grouped_contact_list.dart';
import 'package:lantern/messaging/messaging.dart';

@RoutePage(name: 'Introduce')
class Introduce extends StatefulWidget {
  final bool singleIntro;
  final Contact? contactToIntro;

  Introduce({required this.singleIntro, this.contactToIntro}) : super();

  @override
  _IntroduceState createState() => _IntroduceState();
}

class _IntroduceState extends State<Introduce> {
  List<String> selectedContactIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.singleIntro
        ? 'introduce_contact'.i18n
        : 'introduce_contacts_with_count'
            .i18n
            .fill([selectedContactIds.length]);

    final text = widget.singleIntro
        ? 'introduce_single_contact'.i18n.fill([
            widget.contactToIntro != null
                ? widget.contactToIntro!.displayNameOrFallback
                : ''
          ])
        : 'introduce_contacts_select'.i18n;
    return BaseScreen(
      title: title,
      body: messagingModel.contacts(
        builder: (
          context,
          Iterable<PathAndValue<Contact>> _contacts,
          Widget? child,
        ) {
          Iterable<PathAndValue<Contact>> _sortedContacts = [];

          //* remove the contact that is currently being introduced to other contacts
          _sortedContacts = widget.contactToIntro != null
              ? _contacts
                  .where((element) => element.value != widget.contactToIntro)
              : _contacts;

          //* remove unaccepted, blocked and Me contacts, sort alphabetically
          var sortedContacts = _sortedContacts
              .where(
                (element) =>
                    element.value.isAccepted() &&
                    !element.value.isMe &&
                    element.value.isNotBlocked(),
              )
              .toList()
              .sortedAlphabetically();

          //* group by initial character
          var groupedSortedContacts = sortedContacts
              .groupBy((el) => el.value.displayNameOrFallback[0].toLowerCase());

          final contactsThreshold = widget.singleIntro ? 1 : 2;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (sortedContacts.length < contactsThreshold)
                    ? const NotEnoughContacts()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: groupedContactListGenerator(
                              headItems: sortedContacts.isEmpty
                                  ? null
                                  : [
                                      Container(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                          start: 4.0,
                                          end: 4.0,
                                          top: 16.0,
                                          bottom: 16.0,
                                        ),
                                        child: CText(text, style: tsBody1),
                                      )
                                    ],
                              groupedSortedList: groupedSortedContacts,
                              leadingCallback: (Contact contact) =>
                                  CustomAvatar(
                                messengerId: contact.contactId.id,
                                displayName: contact.displayName,
                              ),
                              disableSplash: !widget.singleIntro,
                              trailingCallback: (
                                int index,
                                Contact contact,
                              ) =>
                                  widget.singleIntro &&
                                          widget.contactToIntro != null
                                      //* single contact intro
                                      ? const ContinueArrow()
                                      //* multiple contact intro
                                      : Checkbox(
                                          checkColor: Colors.white,
                                          fillColor:
                                              MaterialStateProperty.resolveWith(
                                            (states) => getCheckboxFillColor(
                                              black,
                                              states,
                                            ),
                                          ),
                                          value: selectedContactIds.contains(
                                            contact.contactId.id,
                                          ),
                                          shape: const CircleBorder(
                                            side: BorderSide.none,
                                          ),
                                          onChanged: (bool? value) =>
                                              setState(() {
                                            value!
                                                ? selectedContactIds.add(
                                                    contact.contactId.id,
                                                  )
                                                : selectedContactIds.remove(
                                                    contact.contactId.id,
                                                  );
                                          }),
                                        ),
                              onTapCallback: (Contact contact) async {
                                if (widget.singleIntro) {
                                  await messagingModel.introduce([
                                    widget.contactToIntro!.contactId.id,
                                    contact.contactId.id
                                  ]);
                                  showSnackbar(
                                    context: context,
                                    content: 'introductions_sent'.i18n,
                                  );
                                  await context.router.maybePop();
                                }
                              },
                            ),
                          ),
                          //* BUTTON
                          if (!widget.singleIntro)
                            Container(
                              color: white,
                              padding: const EdgeInsetsDirectional.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Button(
                                    text:
                                        'send_introductions'.i18n.toUpperCase(),
                                    disabled: selectedContactIds.length < 2,
                                    onPressed: () async {
                                      await messagingModel.introduce(
                                        selectedContactIds,
                                      );
                                      showSnackbar(
                                        context: context,
                                        content: 'introductions_sent'.i18n,
                                      );
                                      await context.router.maybePop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          // HACK - create transparent tiny text to be picked up by testing and select all checkboxes
                          GestureDetector(
                            key: const ValueKey('select_all_intros'),
                            onTap: () => sortedContacts.forEach((e) {
                              setState(() {
                                selectedContactIds.add(e.value.contactId.id);
                              });
                            }),
                            child: CText(
                              'hack',
                              style: tsOverline.copiedWith(color: transparent),
                            ),
                          ),
                        ],
                      ),
              )
            ],
          );
        },
      ),
    );
  }
}

class NotEnoughContacts extends StatelessWidget {
  const NotEnoughContacts({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24.0),
        child: CText(
          'need_two_contacts_to_introduce'.i18n,
          style: tsSubtitle1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
