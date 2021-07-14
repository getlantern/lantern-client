import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/contact.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:auto_route/auto_route.dart';

class Contacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
        title: 'Contacts'.i18n,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search'.i18n,
            onPressed: () => {},
          ),
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
              return Column(
                children: [
                  ContactItem(contacts[index]),
                  CustomDivider(height: 1),
                ],
              );
            },
          );
        }),
        actionButton: FloatingActionButton(
          onPressed: () async => await context.pushRoute(const NewMessage()),
          child: const Icon(Icons.add),
        ));
  }
}
