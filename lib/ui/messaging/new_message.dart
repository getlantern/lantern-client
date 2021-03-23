import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class NewMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'New Message'.i18n,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text('Add Contact'.i18n),
          onTap: () {
            Navigator.restorablePushNamed(context, 'add_contact');
          },
        ),
        Divider(thickness: 1),
        ListTile(
          leading: Icon(Icons.group_add),
          title: Text('New Group Message'.i18n),
        ),
        Divider(thickness: 1),
        Expanded(
          child: model.contacts(
              builder: (context, List<Contact> contacts, Widget child) {
            var recentContacts = contacts.take(10).toList();
            contacts.sort((a, b) {
              var dc = (a.displayName ?? "").compareTo(b.displayName ?? "");
              if (dc != 0) {
                return dc;
              }
              return a.id.compareTo(b.id);
            });
            var all = recentContacts + contacts;
            return ListView.builder(
              itemCount: all.length,
              itemBuilder: (context, index) {
                var contact = all[index];
                return ListTile(
                  title: Text(contact.displayName?.isEmpty
                      ? 'Unnamed'.i18n
                      : contact.displayName),
                  subtitle: Text(contact.id, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pushNamed(context, 'conversation',
                        arguments: contact);
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
