import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';

import 'widgets/contacts/contact_message_preview.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
        title: 'Messages'.i18n,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search'.i18n,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Your Contact Info'.i18n,
            onPressed: () async => await context.pushRoute(
              const ContactInfo(),
            ),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: CustomBadge(
                  count: 1,
                  showBadge: true,
                  child: const Icon(
                    Icons.people,
                    color: Colors.black,
                  ),
                ),
                title: Text('Introductions'.i18n, style: tsBaseScreenBodyText),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                onTap: () async =>
                    await context.pushRoute(const Introductions()),
              ),
            ),
            Expanded(
              child: model.contactsByActivity(builder: (context,
                  Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
                var contacts = _contacts
                    .where((contact) => contact.value.mostRecentMessageTs > 0)
                    .toList();
                contacts.sort((a, b) {
                  return (b.value.mostRecentMessageTs -
                          a.value.mostRecentMessageTs)
                      .toInt();
                });
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    // false will style this as a Message preview
                    return Column(
                      children: [
                        ContactMessagePreview(contacts[index], index, false),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
        actionButton: FloatingActionButton(
          onPressed: () async => await context.pushRoute(const NewMessage()),
          child: const Icon(Icons.add),
        ));
  }
}
