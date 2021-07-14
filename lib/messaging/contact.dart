import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:auto_route/auto_route.dart';

/// An item in a conversation list.
class ContactItem extends StatelessWidget {
  final PathAndValue<Contact> _contact;

  ContactItem(this._contact) : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.contact(context, _contact,
        (BuildContext context, Contact contact, Widget? child) {
      return ListTile(
        leading: const Icon(
          Icons.account_circle,
          size: 40,
          color: Colors.black,
        ),
        title: Text(
            contact.displayName.isEmpty
                ? 'Unnamed contact'.i18n
                : contact.displayName,
            style: const TextStyle(fontWeight: FontWeight.normal)),
        subtitle: Text(contact.contactId.id.toString()),
        onTap: () async =>
            await context.pushRoute(ContactOptions(contact: _contact)),
      );
    });
  }
}
