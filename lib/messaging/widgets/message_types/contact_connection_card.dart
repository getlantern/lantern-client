import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/utils/show_alert_dialog.dart';
import 'package:sizer/sizer.dart';

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
    var contactName = sanitizeContactName(contact);
    // TODO (Connect Friends PR): temporary
    var requestAccepted = false;
    var requestRejected = false;
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment:
          outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: outbound ? 60.w : 100.w,
          padding: const EdgeInsets.only(top: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: avatarBgColors[
                  generateUniqueColorIndex(contact.contactId.id)],
              child: Text(avatarLetters.toUpperCase(),
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(contactName,
                style: TextStyle(
                    color: outbound ? outboundMsgColor : inboundMsgColor)),
            trailing: outbound
                ? const SizedBox()
                : FittedBox(
                    child: Row(
                      children: [
                        if (requestAccepted)
                          Icon(Icons.check_circle,
                              color: outbound
                                  ? outboundMsgColor
                                  : inboundMsgColor),
                        IconButton(
                          icon: Icon(
                              !(requestAccepted && requestRejected)
                                  ? Icons.info_outline_rounded
                                  : Icons.arrow_right_outlined,
                              size: 20.0,
                              color: outbound
                                  ? outboundMsgColor
                                  : inboundMsgColor),
                          onPressed: () async {
                            if (!(requestAccepted && requestRejected)) {
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
                      ],
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
                        dense: true,
                        leading:
                            const Icon(Icons.check_circle, color: Colors.black),
                        title: Text('Accept'.i18n),
                        onTap: () {
                          // requestAccepted = true
                          // model.acceptReq()
                          // slight delay to let checkbox show
                          // dismiss modal
                          // navigate to conversation
                        }),
                    Divider(thickness: 1, color: grey2),
                    ListTile(
                      leading: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      title: Text('Reject'.i18n),
                      onTap: () {
                        // requestAccepted = false
                        // model.rejectReq()
                        // dismiss modal
                        showAlertDialog(
                            context: context,
                            title: Text('Reject Introduction?'.i18n,
                                style: tsAlertDialogTitle),
                            content: Text(
                                'You will not be able to message this contact if you reject the introduction.'
                                    .i18n,
                                style: tsAlertDialogBody),
                            dismissText: 'Cancel'.i18n,
                            agreeText: 'Reject'.i18n);
                      },
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
