import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/widgets/contacts/add_contact_QR.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/contacts/generate_grouped_list.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/iterable_extension.dart';

class NewMessage extends StatelessWidget {
  static const NUM_RECENT_CONTACTS = 10;

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

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
              title: Text('Scan QR Code'.i18n),
              trailing: const CustomAssetImage(
                path: ImagePaths.keyboard_arrow_right_icon,
                size: 24,
              ),
              onTap: () async => await context.router.push(
                FullScreenDialogPage(widget: AddViaQR()),
              ),
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
                var contacts = _contacts.toList();
                return ListTile(
                    title: Text(
                        contacts.isNotEmpty
                            ? 'Recent contacts'.i18n.toUpperCase()
                            : 'No contacts have been added yet'
                                .i18n
                                .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        )));
              }),
            ),
            Flexible(child: model.contacts(builder: (context,
                Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
              var contacts = _contacts.toList();

              var recentContacts = contacts.take(NUM_RECENT_CONTACTS).toList();
              // related https://github.com/getlantern/android-lantern/issues/299
              var sortedRecentContacts = recentContacts
                ..sort((a, b) => sanitizeContactName(a.value)
                    .toLowerCase()
                    .toString()
                    .compareTo(
                        sanitizeContactName(b.value).toLowerCase().toString()));

              var groupedSortedRecentContacts = sortedRecentContacts.groupBy(
                  (el) => sanitizeContactName(el.value)[0]
                      .toLowerCase()
                      .toString());
              return groupedSortedRecentContacts.isEmpty
                  ? Container()
                  : groupedContactListGenerator(
                      groupedSortedList: groupedSortedRecentContacts,
                      leadingCallback: (Contact contact) => CircleAvatar(
                            backgroundColor: avatarBgColors[
                                generateUniqueColorIndex(contact.contactId.id)],
                            child: Text(
                                sanitizeContactName(contact)
                                    .substring(0, 2)
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white)),
                          ),
                      onTapCallback: (Contact contact) async => await context
                          .pushRoute(Conversation(contact: contact)));
            }))
          ]),
    );
  }
}
