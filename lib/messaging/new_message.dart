import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/widgets/add_contact_QR.dart';
import 'package:lantern/messaging/messaging_model.dart';
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
              trailing: const Icon(Icons.keyboard_arrow_right_outlined),
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
              trailing: const Icon(Icons.keyboard_arrow_right_outlined),
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

              // TODO:define a List extension?
              // alphabetically sort contacts
              var recentConversations = contacts
                  .take(NUM_RECENT_CONTACTS)
                  .toList()
                    ..sort((a, b) => sanitizeContactName(a.value)
                        .toLowerCase()
                        .toString()
                        .compareTo(sanitizeContactName(b.value)
                            .toLowerCase()
                            .toString()));

              // TODO:this fails for title starting with emojis
              var groupedRecentConversations = recentConversations.groupBy(
                  (el) => sanitizeContactName(el.value)[0]
                      .toLowerCase()
                      .toString());

              groupedRecentConversations.isEmpty
                  ? Container()
                  : groupedContactListGenerator(groupedRecentConversations);
            }))
          ]),
    );
  }
}
