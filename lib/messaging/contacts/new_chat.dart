import 'package:lantern/messaging/contacts/add_contact_QR.dart';
import 'package:lantern/messaging/contacts/grouped_contact_list.dart';
import 'package:lantern/messaging/messaging.dart';

import 'long_tap_menu.dart';

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
            textColor: pink3,
            label: 'start_chat'.i18n.toUpperCase(),
            onPressed: () async {
              await context.pushRoute(
                  Conversation(contactId: _updatedContact!.contactId));
            },
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

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
      body: model.me(
        (BuildContext context, Contact me, Widget? child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*
              * Share your Chat Number
              */
              ListItemFactory.messagingItem(
                header: 'add_new_contact'.i18n,
                leading: const CAssetImage(
                  path: ImagePaths.share,
                ),
                content: CText('share_your_chat_number'.i18n,
                    style: tsSubtitle1Short),
                trailingArray: [
                  mirrorLTR(
                    context: context,
                    child: const CAssetImage(
                      path: ImagePaths.keyboard_arrow_right,
                    ),
                  )
                ],
                onTap: () {}, // TODO: Trigger native sharing
              ),
              /*
              * Scan QR Code
              */
              ListItemFactory.messagingItem(
                leading: const CAssetImage(
                  path: ImagePaths.qr_code_scanner,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CText('scan_qr_code'.i18n, style: tsSubtitle1Short),
                    CText('add_contact_in_person'.i18n,
                        style: tsBody1.copiedWith(color: grey5))
                  ],
                ),
                trailingArray: [
                  mirrorLTR(
                    context: context,
                    child: const CAssetImage(
                      path: ImagePaths.keyboard_arrow_right,
                    ),
                  )
                ],
                onTap: () async => await context
                    .pushRoute(
                      FullScreenDialogPage(
                          widget: AddViaQR(
                        me: me,
                        isVerificationMode: false,
                      )),
                    )
                    .then(onContactAdded),
              ),
              /*
              * Add via Chat Number
              */
              ListItemFactory.messagingItem(
                leading: const CAssetImage(
                  path: ImagePaths.person_add_alt_1,
                ),
                content:
                    CText('add_via_chat_number'.i18n, style: tsSubtitle1Short),
                trailingArray: [
                  mirrorLTR(
                    context: context,
                    child: const CAssetImage(
                      path: ImagePaths.keyboard_arrow_right,
                    ),
                  )
                ],
                onTap: () async => await context
                    .pushRoute(const AddViaChatNumber())
                    .then(onContactAdded),
              ),
              /*
              * Contact List
              */
              Flexible(child: model.contacts(builder: (context,
                  Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
                var contacts = _contacts
                    .where((element) =>
                        element.value.verificationLevel !=
                            VerificationLevel.UNACCEPTED &&
                        !element.value.blocked)
                    .toList();

                // related https://github.com/getlantern/android-lantern/issues/299
                var sortedContacts = contacts.sortedAlphabetically();

                var groupedSortedContacts = sortedContacts.groupBy(
                    (el) => el.value.displayNameOrFallback[0].toLowerCase());

                // scroll to index of the contact we just added, if there is one
                // otherwise start from top (index = 0)
                var scrollIndex = _updatedContact != null
                    ? sortedContacts.indexWhere((element) =>
                        element.value.contactId.id ==
                        _updatedContact!.contactId.id)
                    : 0;
                if (scrollListController.isAttached) {
                  scrollListController.scrollTo(
                      index: scrollIndex != -1 ? scrollIndex : 0,
                      //if recent contact can not be found in our list for some reason
                      duration: const Duration(milliseconds: 300));
                }

                return groupedSortedContacts.isNotEmpty
                    ? groupedContactListGenerator(
                        groupedSortedList: groupedSortedContacts,
                        scrollListController: scrollListController,
                        leadingCallback: (Contact contact) => CustomAvatar(
                            messengerId: contact.contactId.id,
                            displayName: contact.displayNameOrFallback),
                        onTapCallback: (Contact contact) async =>
                            await context.pushRoute(
                                Conversation(contactId: contact.contactId)),
                        focusMenuCallback: (Contact contact) =>
                            renderLongTapMenu(
                                contact: contact, context: context))
                    : Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsetsDirectional.all(16.0),
                        child: CText('no_contacts_yet'.i18n,
                            textAlign: TextAlign.center,
                            style:
                                tsSubtitle1Short)); // rendering this instead of SizedBox() to avoid null dimension errors
              })),
            ],
          );
        },
      ),
    );
  }
}
