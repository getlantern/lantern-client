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
        body: model.contacts(builder: (context,
            Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
          var contacts = _contacts.toList();
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  // true will render the new_message route
                  ContactItem(contacts[index], index, true),
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
