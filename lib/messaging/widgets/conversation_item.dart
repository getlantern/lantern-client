import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

import '../messaging_model.dart';

class ConversationItem extends StatelessWidget {
  final PathAndValue<Contact> contact;

  ConversationItem(this.contact) : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.contact(context, contact,
        (BuildContext context, Contact contact, Widget child) {
      return ListTile(
        title: Text(
            contact.displayName != null && contact.displayName.isEmpty
                ? 'Unnamed'.i18n
                : contact.displayName,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            "${contact.mostRecentMessageDirection == MessageDirection.OUT ? 'Me'.i18n + ': ' : ''}${contact.mostRecentMessageText.isNotEmpty ? contact.mostRecentMessageText : 'attachment'.i18n}",
            overflow: TextOverflow.ellipsis),
        onTap: () async {
          Navigator.pushNamed(context, '/conversation', arguments: contact);
        },
      );
    });
  }
}
