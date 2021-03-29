import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class Conversations extends StatefulWidget {
  @override
  _ConversationsState createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  static const int pageLength = 25;

  MessagingModel model;

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();

    return BaseScreen(
        title: 'Messages'.i18n,
        actions: [
          IconButton(
              icon: Icon(Icons.qr_code),
              tooltip: "Your Contact Info".i18n,
              onPressed: () {
                Navigator.restorablePushNamed(context, 'your_contact_info');
              }),
        ],
        body: model.contacts(builder:
            (context, List<PathAndValue<Contact>> contacts, Widget child) {
          contacts.sort((a, b) {
            return (b.value.mostRecentMessageTs - a.value.mostRecentMessageTs)
                .toInt();
          });
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              var contact = contacts[index];
              return ListTile(
                title: Text(
                    contact.value.displayName?.isEmpty
                        ? 'Unnamed'.i18n
                        : contact.value.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "${contact.value.mostRecentMessageDirection == MessageDirection.OUT ? 'Me'.i18n + ': ' : ''}${contact.value.mostRecentMessageText}",
                    overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.pushNamed(context, 'conversation',
                      arguments: contact.value);
                },
              );
            },
          );
        }),
        actionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.restorablePushNamed(context, 'new_message');
          },
        ));
  }
}
