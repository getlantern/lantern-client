import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';

/// An item in a conversation list.
class ContactItem extends StatelessWidget {
  final PathAndValue<Contact> _contact;
  final int _index;
  final bool _renderNewMessage;

  ContactItem(this._contact, this._index, this._renderNewMessage) : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return model.contact(context, _contact,
        (BuildContext context, Contact contact, Widget? child) {
      var topBorderWidth = _index.isEven ? 0.5 : 0.0;
      var bottomBorderWidth = _index.isOdd ? 0.0 : 0.5;
      var displayName = contact.displayName.isEmpty
          ? 'Unnamed contact'.i18n
          : contact.displayName;
      var avatarLetters = displayName.substring(0, 2);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(width: topBorderWidth, color: Colors.black12),
          bottom: BorderSide(width: bottomBorderWidth, color: Colors.black12),
        )),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.pink[800],
            child: Text(avatarLetters.toUpperCase(),
                style: const TextStyle(color: Colors.white)),
          ),
          title: Text(displayName,
              style: const TextStyle(fontWeight: FontWeight.normal)),
          subtitle: Text(contact.contactId.id.toString(),
              style: const TextStyle(fontSize: 10.0)),
          onTap: () async => await context.pushRoute(_renderNewMessage
              ? ContactOptions(contact: _contact)
              : Conversation(contact: _contact.value)
                  as PageRouteInfo<dynamic>),
        ),
      );
    });
  }
}
