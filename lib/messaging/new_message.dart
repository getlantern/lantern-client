import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/humanize.dart';

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
            onPressed: () {
              Navigator.restorablePushNamed(context, '/your_contact_info');
            }),
      ],
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          leading: const Icon(Icons.person_add),
          title: Text('Add Contact'.i18n),
          onTap: () {
            Navigator.restorablePushNamed(context, '/add_contact');
          },
        ),
        const Divider(thickness: 1),
        ListTile(
          leading: const Icon(Icons.group_add),
          title: Text('New Group Message'.i18n),
        ),
        const Divider(thickness: 1),
        Expanded(
          child: model.contacts(builder: (context,
              Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
            var contacts = _contacts.toList();
            var all = contacts.take(NUM_RECENT_CONTACTS).toList();
            if (contacts.length > NUM_RECENT_CONTACTS) {
              contacts.sort((a, b) {
                var dc = (a.value.displayName)
                    .compareTo(b.value.displayName);
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
                return ListTile(
                  title: Text(
                      contact.value.displayName.isEmpty
                          ? 'Unnamed'.i18n
                          : contact.value.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'added '.i18n +
                          contact.value.createdTs.toInt().humanizeDate(),
                      overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pushNamed(context, '/conversation',
                        arguments: contact.value);
                  },
                );
              },
            );
          }),
        )
      ]),
    );
  }
}
