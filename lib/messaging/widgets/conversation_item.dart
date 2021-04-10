import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:pedantic/pedantic.dart';

import '../messaging_model.dart';

/// An item in a conversation list.
class ConversationItem extends StatelessWidget {
  final PathAndValue<Contact> _contact;

  ConversationItem(this._contact) : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.contact(context, _contact,
        (BuildContext context, Contact contact, Widget? child) {
      return ListTile(
        title: Text(
            contact.displayName.isEmpty ? 'Unnamed'.i18n : contact.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            "${contact.mostRecentMessageDirection == MessageDirection.OUT ? 'Me'.i18n + ': ' : ''}${contact.mostRecentMessageText.isNotEmpty ? contact.mostRecentMessageText : 'attachment'.i18n}",
            overflow: TextOverflow.ellipsis),
        onTap: () async {
          unawaited(Navigator.pushNamed(context, '/conversation',
              arguments: contact));
        },
      );
    });
  }
}
