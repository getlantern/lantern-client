import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/widgets/add_contact_QR.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

import 'widgets/add_contact_username.dart';
import 'widgets/contact_message_preview.dart';

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
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          leading: const Icon(Icons.person_add),
          title: Text('Add Contact by username'.i18n),
          trailing: const Icon(Icons.keyboard_arrow_right_outlined),
          onTap: () async => await context.router.push(
            FullScreenDialogPage(widget: AddViaUsername()),
          ),
        ),
        const Divider(thickness: 1),
        ListTile(
          leading: const Icon(Icons.qr_code),
          title: Text('Scan QR Code'.i18n),
          trailing: const Icon(Icons.keyboard_arrow_right_outlined),
          onTap: () async => await context.router.push(
            FullScreenDialogPage(widget: AddViaQR()),
          ),
        ),
        const Divider(thickness: 1),
        Container(
          child: model.contacts(builder: (context,
              Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
            var contacts = _contacts.toList();
            return ListTile(
                title: Text(
                    contacts.isNotEmpty
                        ? 'Recent contacts'.i18n.toUpperCase()
                        : 'No contacts have been added yet'.i18n.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    )));
          }),
        ),
        Expanded(
          child: model.contacts(builder: (context,
              Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
            var contacts = _contacts.toList();
            var all = contacts.take(NUM_RECENT_CONTACTS).toList();
            if (contacts.length > NUM_RECENT_CONTACTS) {
              contacts.sort((a, b) {
                var dc = (a.value.displayName).compareTo(b.value.displayName);
                if (dc != 0) {
                  return dc;
                }
                return a.value.contactId.id.compareTo(b.value.contactId.id);
              });
              all += contacts;
            }
            return ListView.builder(
              itemCount: all.length,
              itemBuilder: (context, index) {
                var contact = all[index];
                return Column(
                  children: [
                    // true will style this as a Contact preview
                    ContactMessagePreview(contact, index, true),
                  ],
                );
              },
            );
          }),
        )
      ]),
    );
  }
}
