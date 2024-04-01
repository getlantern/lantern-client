import 'package:lantern/messaging/contacts/add_contact_QR.dart';
import 'package:lantern/messaging/contacts/grouped_contact_list.dart';
import 'package:lantern/messaging/messaging.dart';

import 'long_tap_menu.dart';

@RoutePage<void>(name: 'NewChat')
class NewChat extends StatefulWidget {
  @override
  _NewChatState createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  var scrollListController = ItemScrollController();
  Contact? _updatedContact;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onContactAdded(dynamic contact) {
    if (contact != null) {
      setState(() {
        _updatedContact = contact;
      });
      showSnackbar(
        context: context,
        content: 'qr_success_snackbar'
            .i18n
            .fill([_updatedContact!.displayNameOrFallback]),
        duration: const Duration(milliseconds: 4000),
        action: SnackBarAction(
          textColor: yellow4,
          label: 'start_chat'.i18n.toUpperCase(),
          onPressed: () async {
            await context.pushRoute(
              Conversation(contactId: _updatedContact!.contactId),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'new_chat'.i18n,
      actions: [
        RoundButton(
          onPressed: () async => await showSearch(
            context: context,
            query: '',
            delegate: CustomSearchDelegate(),
          ),
          backgroundColor: transparent,
          icon: const CAssetImage(path: ImagePaths.search),
        ),
      ],
      body: messagingModel.me(
        (BuildContext context, Contact me, Widget? child) {
          return messagingModel.contacts(
            builder: (
              context,
              Iterable<PathAndValue<Contact>> _contacts,
              Widget? child,
            ) {
              var contacts = _contacts
                  .where(
                    (element) =>
                        element.value.isAccepted() &&
                        element.value.isNotBlocked(),
                  )
                  .toList();

              // related https://github.com/getlantern/android-lantern/issues/299
              var sortedContacts = contacts.sortedAlphabetically();

              var groupedSortedContacts = sortedContacts.groupBy(
                (el) => el.value.displayNameOrFallback[0].toLowerCase(),
              );

              // scroll to index of the contact we just added, if there is one
              // otherwise start from top (index = 0)
              var scrollIndex = _updatedContact != null
                  ? sortedContacts.indexWhere(
                      (element) =>
                          element.value.contactId.id ==
                          _updatedContact!.contactId.id,
                    )
                  : 0;
              if (scrollListController.isAttached && scrollIndex != -1) {
                scrollListController.scrollTo(
                  index: scrollIndex,
                  duration: const Duration(milliseconds: 300),
                );
              }

              return groupedSortedContacts.isNotEmpty
                  ? groupedContactListGenerator(
                      headItems: buildNewChatItems(me),
                      groupedSortedList: groupedSortedContacts,
                      scrollListController: scrollListController,
                      leadingCallback: (Contact contact) => CustomAvatar(
                        messengerId: contact.contactId.id,
                        displayName: contact.displayName,
                      ),
                      onTapCallback: (Contact contact) async =>
                          await context.pushRoute(
                        Conversation(
                          contactId: contact.contactId,
                        ),
                      ),
                      focusMenuCallback: (Contact contact) =>
                          renderLongTapMenu(contact: contact, context: context),
                    )
                  : Container(
                      alignment: AlignmentDirectional.center,
                      padding: const EdgeInsetsDirectional.all(16.0),
                      child: CText(
                        'no_contacts_yet'.i18n,
                        textAlign: TextAlign.center,
                        style: tsSubtitle1Short,
                      ),
                    ); // rendering this instead of SizedBox() to avoid null dimension errors
            },
          );
        },
      ),
    );
  }

  List<Widget> buildNewChatItems(Contact me) {
    return [
      buildAddViaChatNumber(me),
      buildScanQRCode(me),
      ShareYourChatNumber(me).messagingItem,
    ];
  }

  Widget buildAddViaChatNumber(Contact me) {
    return ListItemFactory.messagingItem(
      header: 'add_new_contact'.i18n,
      leading: const CAssetImage(
        path: ImagePaths.person_add_alt_1,
      ),
      content: CText('add_via_chat_number'.i18n, style: tsSubtitle1Short),
      trailingArray: [const ContinueArrow()],
      onTap: () async => await context
          .pushRoute(const AddViaChatNumber())
          .then(onContactAdded),
    );
  }

  Widget buildScanQRCode(Contact me) {
    return ListItemFactory.messagingItem(
      leading: const CAssetImage(
        path: ImagePaths.qr_code_scanner,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CText('scan_qr_code'.i18n, style: tsSubtitle1Short),
          CText(
            'add_contact_in_person'.i18n,
            style: tsBody1.copiedWith(color: grey5),
          )
        ],
      ),
      trailingArray: [const ContinueArrow()],
      onTap: () async => await context
          .pushRoute(
            FullScreenDialogPage(
              widget: AddViaQR(
                me: me,
                isVerificationMode: false,
              ),
            ),
          )
          .then(onContactAdded),
    );
  }
}
