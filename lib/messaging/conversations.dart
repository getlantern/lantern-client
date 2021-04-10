import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/conversation_item.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class Conversations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
        title: 'Messages'.i18n,
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code),
              tooltip: 'Your Contact Info'.i18n,
              onPressed: () {
                Navigator.restorablePushNamed(context, '/your_contact_info');
              }),
        ],
        body: model.contactsByActivity(builder: (context,
            Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
          var contacts = _contacts
              .where((contact) => contact.value.mostRecentMessageTs > 0)
              .toList();
          contacts.sort((a, b) {
            return (b.value.mostRecentMessageTs - a.value.mostRecentMessageTs)
                .toInt();
          });
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return ConversationItem(contacts[index]);
            },
          );
        }),
        actionButton: FloatingActionButton(
          onPressed: () {
            Navigator.restorablePushNamed(context, '/new_message');
          },
          child: const Icon(Icons.add),
        ));
  }
}
