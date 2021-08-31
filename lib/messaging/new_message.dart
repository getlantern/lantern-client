import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/widgets/contacts/add_contact_QR.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/contacts/grouped_contact_list.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/iterable_extension.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:lantern/core/router/router_extensions.dart';

class NewMessage extends StatelessWidget {
  static const NUM_RECENT_CONTACTS = 10;

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    var contactListController = ItemScrollController();

    return BaseScreen(
      title: 'New Message'.i18n,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search'.i18n,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.qr_code),
          tooltip: 'Your Contact Info'.i18n,
          onPressed: () async => await context.pushRoute(const ContactInfo()),
        ),
      ],
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(
                Icons.qr_code,
                color: Colors.black,
              ),
              title: Text('Scan Contact QR Code'.i18n),
              trailing: const CustomAssetImage(
                path: ImagePaths.keyboard_arrow_right_icon,
                size: 24,
              ),
              onTap: () async => await context.router
                  .push(
                FullScreenDialogPage(widget: AddViaQR()),
              )
                  .then((value) {
                if (value != null) {
                  var updatedContact = value as Contact;
                  var scrollToIndex = 1;
                  if (contactListController.isAttached) {
                    contactListController.scrollTo(
                        index: scrollToIndex,
                        duration: const Duration(milliseconds: 300));
                  }

                  showSnackbar(
                      context: context,
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              'Contact added'.i18n,
                              overflow: TextOverflow.visible,
                              style: txSnackBarText,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 4000),
                      action: SnackBarAction(
                        textColor: secondaryPink,
                        label: 'START CHAT'.toUpperCase().i18n,
                        onPressed: () async {
                          await context
                              .openConversation(updatedContact.contactId);
                        },
                      ));
                }
              }),
            ),
            Divider(thickness: 1, color: grey2),
            ListTile(
              leading: const Icon(
                Icons.people,
                color: Colors.black,
              ),
              title: Text('Introduce Contacts'.i18n),
              trailing: const CustomAssetImage(
                path: ImagePaths.keyboard_arrow_right_icon,
                size: 24,
              ),
              onTap: () async => await context.pushRoute(const Introduce()),
            ),
            Divider(thickness: 1, color: grey2),
            Container(
              child: model.contacts(builder: (context,
                  Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
                return _contacts.toList().isNotEmpty
                    ? ListTile(
                        title: Text('Recent contacts'.i18n.toUpperCase(),
                            style: tsEmptyContactState))
                    : Container();
              }),
            ),
            TextButton(
                onPressed: () {
                  if (contactListController.isAttached) {
                    contactListController.scrollTo(
                        index: 1, duration: const Duration(milliseconds: 300));
                  }
                },
                child: Text('scroll test')),
            Container(
              height: 150,
              child: Flexible(child: model.contacts(builder: (context,
                  Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
                var contacts = _contacts.toList();

                var recentContacts =
                    contacts.take(NUM_RECENT_CONTACTS).toList();
                // related https://github.com/getlantern/android-lantern/issues/299
                var sortedRecentContacts = recentContacts
                  ..sort((a, b) => sanitizeContactName(a.value.displayName)
                      .compareTo(sanitizeContactName(b.value.displayName)));

                var groupedSortedRecentContacts = sortedRecentContacts
                    .groupBy((el) => sanitizeContactName(el.value.displayName));

                return groupedSortedRecentContacts.isNotEmpty
                    ? groupedContactListGenerator(
                        groupedSortedList: groupedSortedRecentContacts,
                        contactListController: contactListController,
                        leadingCallback: (Contact contact) => CircleAvatar(
                              backgroundColor: avatarBgColors[
                                  generateUniqueColorIndex(
                                      contact.contactId.id)],
                              child: Text(
                                  sanitizeContactName(contact.displayName)
                                      .substring(0, 2)
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.white)),
                            ),
                        onTapCallback: (Contact contact) async =>
                            await context.pushRoute(
                                Conversation(contactId: contact.contactId)))
                    : Container(
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Text('No contacts yet.'.i18n,
                            textAlign: TextAlign.center,
                            style:
                                tsEmptyContactState)); // rendering this instead of SizedBox() to avoid null dimension errors
              })),
            )
          ]),
    );
  }
}
