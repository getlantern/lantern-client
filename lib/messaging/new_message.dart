import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';

class NewMessage extends StatelessWidget {
  static const NUM_RECENT_CONTACTS = 10;

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'New Message'.i18n,
      actions: [
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
          onTap: () async => await context.pushRoute(const AddUsername()),
        ),
        const Divider(thickness: 1),
        ListTile(
          leading: const Icon(Icons.qr_code),
          title: Text('Scan QR Code'.i18n),
          trailing: const Icon(Icons.keyboard_arrow_right_outlined),
          onTap: () async => await context.pushRoute(const AddQR()),
        ),
        const Divider(thickness: 1),
        ListTile(
            title: Text('Recent contacts'.i18n,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ))),
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
                var topBorderWidth = index.isEven ? 0.5 : 0.0;
                var bottomBorderWidth = index.isOdd ? 0.0 : 0.5;
                return Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                        border: Border(
                      top: BorderSide(
                          width: topBorderWidth, color: Colors.black12),
                      bottom: BorderSide(
                          width: bottomBorderWidth, color: Colors.black12),
                    )),
                    child: ListTile(
                      leading: const Icon(
                        Icons.account_circle,
                        size: 25,
                        color: Colors.black,
                      ),
                      title: Text(contact.value.displayName.isEmpty
                          ? 'Unnamed contact'.i18n
                          : contact.value.displayName),
                      onTap: () async => await context.pushRoute(
                        Conversation(contact: contact.value),
                      ),
                    ));
              },
            );
          }),
        )
      ]),
    );
  }
}
