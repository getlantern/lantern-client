import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_types/status_row.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/utils/show_alert_dialog.dart';

class ContactConnectionCard extends StatelessWidget {
  final Contact contact;
  final bool inbound;
  final bool outbound;
  final StoredMessage msg;
  final PathAndValue<StoredMessage> message;
  final List<dynamic> reactionsList;

  ContactConnectionCard(
    this.contact,
    this.inbound,
    this.outbound,
    this.msg,
    this.message,
    this.reactionsList,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();
    final introduction = msg.introduction;
    final avatarLetters = introduction.displayName != ''
        ? introduction.displayName.substring(0, 2)
        : 'UC';
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment:
          outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: outbound ? constraints.maxWidth * 0.6 : constraints.maxWidth,
            padding: const EdgeInsets.only(top: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: avatarBgColors[
                    generateUniqueColorIndex(introduction.to.id)],
                child: Text(avatarLetters.toUpperCase(),
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(introduction.displayName,
                  style: TextStyle(
                      color: outbound ? outboundMsgColor : inboundMsgColor)),
              trailing: outbound
                  ? const SizedBox()
                  : FittedBox(
                      child: Row(
                        children: [
                          if (msg.introduction.status ==
                              IntroductionDetails_IntroductionStatus.ACCEPTED)
                            Icon(Icons.check_circle,
                                color: outbound
                                    ? outboundMsgColor
                                    : inboundMsgColor),
                          Icon(
                              (msg.introduction.status ==
                                      IntroductionDetails_IntroductionStatus
                                          .PENDING)
                                  ? Icons.info_outline_rounded
                                  : Icons.keyboard_arrow_right_outlined,
                              size: (msg.introduction.status ==
                                      IntroductionDetails_IntroductionStatus
                                          .PENDING)
                                  ? 20.0
                                  : 30.0,
                              color: outbound
                                  ? outboundMsgColor
                                  : inboundMsgColor),
                        ],
                      ),
                    ),
              onTap: () async {
                if (inbound &&
                    msg.introduction.status ==
                        IntroductionDetails_IntroductionStatus.PENDING) {
                  await _showOptions(
                    context,
                    introduction,
                    model,
                    contact,
                  );
                }
                if (msg.introduction.status ==
                    IntroductionDetails_IntroductionStatus.ACCEPTED) {
                  await context
                      .pushRoute(Conversation(contactId: introduction.to));
                }
              },
            ),
          );
        }),
        Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusRow(outbound, inbound, msg, message, reactionsList)
            ])
      ],
    );
  }

  Future<dynamic> _showOptions(BuildContext context,
      IntroductionDetails introduction, MessagingModel model, Contact contact) {
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
                    child: Text(
                        'Accept Introduction to ${introduction.displayName}',
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
                        title: Text('Accept'.i18n, style: tsAlertDialogTitle),
                        onTap: () async {
                          try {
                            // model.acceptIntroduction(from the person who is making the intro, to the person who they want to connect us to)
                            await model.acceptIntroduction(
                                contact.contactId.id, introduction.to.id);
                          } catch (e) {
                            showInfoDialog(context,
                                title: 'Error'.i18n,
                                des:
                                    'Something went wrong while accepting this connect request.'
                                        .i18n,
                                icon: ImagePaths.alert_icon,
                                buttonText: 'OK'.i18n);
                          } finally {
                            await context.router.pop();
                            await context.pushRoute(
                                Conversation(contactId: introduction.to));
                          }
                        }),
                    Divider(thickness: 1, color: grey2),
                    ListTile(
                      leading: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      title: Text('Reject'.i18n),
                      onTap: () async {
                        showAlertDialog(
                            context: context,
                            title: Text('Reject Introduction?'.i18n,
                                style: tsAlertDialogTitle),
                            content: Text(
                                'You will not be able to message this contact if you reject the introduction.'
                                    .i18n,
                                style: tsAlertDialogBody),
                            dismissText: 'Cancel'.i18n,
                            agreeText: 'Reject'.i18n,
                            agreeAction: () async {
                              try {
                                // model.rejectIntroduction(from the person who is making the intro, to the person who they want to connect us to)
                                await model.rejectIntroduction(
                                    contact.contactId.id, introduction.to.id);
                              } catch (e) {
                                showInfoDialog(context,
                                    title: 'Error'.i18n,
                                    des:
                                        'Something went wrong while rejecting this connect request.'
                                            .i18n,
                                    icon: ImagePaths.alert_icon,
                                    buttonText: 'OK'.i18n);
                              } finally {
                                await context.router.pop();
                              }
                            });
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
