import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/utils/humanize.dart';

class ContactMessagePreview extends StatelessWidget {
  final PathAndValue<Contact> _contact;
  final int _index;
  final bool _isContactPreview;

  ContactMessagePreview(this._contact, this._index, this._isContactPreview)
      : super();

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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(width: topBorderWidth, color: Colors.black12),
          bottom: BorderSide(width: bottomBorderWidth, color: Colors.black12),
        )),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                avatarBgColors[generateUniqueColorIndex(contact.contactId.id)],
            child: Text(avatarLetters.toUpperCase(),
                style: const TextStyle(color: Colors.white)),
          ),
          title: Text(
              contact.displayName.isEmpty
                  ? 'Unnamed contact'.i18n
                  : contact.displayName,
              style: TextStyle(
                  fontWeight:
                      _isContactPreview ? FontWeight.normal : FontWeight.bold)),
          subtitle: _isContactPreview
              ? null
              : Text(
                  "${contact.mostRecentMessageText.isNotEmpty ? contact.mostRecentMessageText : 'attachment'.i18n}",
                  overflow: TextOverflow.ellipsis),
          trailing: _isContactPreview
              ? null
              : Text(contact.mostRecentMessageTs
                  .toInt()
                  .humanizeDate()
                  .toString()),
          onTap: () async =>
              await context.pushRoute(Conversation(contact: _contact.value)),
        ),
      );
    });
  }
}
