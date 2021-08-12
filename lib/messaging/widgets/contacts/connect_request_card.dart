import 'package:lantern/messaging/widgets/contact_intro_preview.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

class ConnectRequestCard extends StatelessWidget {
  const ConnectRequestCard({
    Key? key,
    required this.contact,
    required this.index,
  }) : super(key: key);

  final PathAndValue<Contact> contact;
  final int index;

  @override
  Widget build(BuildContext context) {
    var displayName = sanitizeContactName(contact.value);
    var avatarLetters = displayName.substring(0, 2);
    return ContactIntroPreview(
      contact,
      index,
      CircleAvatar(
        backgroundColor: avatarBgColors[
            generateUniqueColorIndex(contact.value.contactId.id)],
        child: Text(avatarLetters.toUpperCase(),
            style: const TextStyle(color: Colors.white)),
      ),
      FittedBox(
        child: Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getCheckboxColor),
          // value: selectedContacts[index]['isSelected'],
          value: false,
          shape: const CircleBorder(side: BorderSide.none),
          // onChanged: (bool? value) => setState(() {
          //   selectedContacts[index]['isSelected'] = value;
          // }),
          onChanged: (bool? value) => {},
        ),
      ),
    );
  }
}
