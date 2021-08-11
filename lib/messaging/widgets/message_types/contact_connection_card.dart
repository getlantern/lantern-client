import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:auto_route/auto_route.dart';

class ContactConnectionCard extends StatelessWidget {
  final Contact contact;
  final bool inbound;
  final bool outbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;

  ContactConnectionCard(
    this.contact,
    this.inbound,
    this.outbound,
    this.msg,
    this.message,
  ) : super();

  @override
  Widget build(BuildContext context) {
    var avatarLetters = contact.displayName.substring(0, 2);
    var contactName = contact.displayName.isEmpty
        ? 'Unnamed contact'.i18n
        : contact.displayName;
    // TODO: temporary
    var requestAccepted = false;
    var actionTaken = true;
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment:
          outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: avatarBgColors[
                  generateUniqueColorIndex(contact.contactId.id)],
              child: Text(avatarLetters.toUpperCase(),
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(contactName),
            trailing: FittedBox(
              child: IconButton(
                icon: Icon(
                    !actionTaken
                        ? Icons.info_outline_rounded
                        : requestAccepted
                            ? Icons.arrow_right_outlined
                            : Icons.cancel,
                    size: 20.0,
                    color: Colors.black),
                onPressed: () async {
                  if (!actionTaken) {
                    await _showOptions(
                      context,
                      contactName,
                    );
                  }
                  if (requestAccepted) {
                    await context.pushRoute(const NewMessage());
                  }
                },
              ),
            ),
          ),
        ),
        Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: [StatusRow(outbound, inbound, msg, message, [])])
      ],
    );
  }

  Future<dynamic> _showOptions(BuildContext context, String contactName) {
    return showModalBottomSheet(
        context: context,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        builder: (context) => Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                ),
                Center(
                    child: Text('Accept Introduction to $contactName',
                        style: tsTitleItem)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  child: Center(
                    child: Text(
                        'Both parties must accept the introduction to message each other.  Introductions disappear after 7 days if no action is taken.'
                            .i18n),
                  ),
                ),
                Divider(thickness: 1, color: grey2),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      leading:
                          const Icon(Icons.check_circle, color: Colors.black),
                      title: Text('Accept'.i18n),
                      onTap: () {},
                    ),
                    Divider(thickness: 1, color: grey2),
                    ListTile(
                      leading: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      title: Text('Reject'.i18n),
                      onTap: () {},
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                ),
              ],
            ));
  }
}
