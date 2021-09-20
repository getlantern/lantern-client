import 'package:lantern/messaging/conversation/status_row.dart';
import 'package:lantern/messaging/messaging.dart';

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
    return Column(
      crossAxisAlignment:
          outbound ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.maxWidth,
            padding: const EdgeInsets.only(top: 10),
            child: ListTile(
              leading: CustomAvatar(
                  id: contact.contactId.id, displayName: contact.displayName),
              title: CText(introduction.displayName,
                  style: tsBody3.copiedWith(
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
                  _showOptions(
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [StatusRow(outbound, inbound, msg, message, reactionsList)],
        )
      ],
    );
  }

  void _showOptions(BuildContext context, IntroductionDetails introduction,
      MessagingModel model, Contact contact) {
    return showBottomModal(
        context: context,
        title: TextOneLine(
            'introductions_title'.fill([introduction.displayName]),
            style: tsSubtitle1),
        subtitle: 'introductions_info'.i18n,
        children: [
          BottomModalItem(
              leading: const CAssetImage(path: ImagePaths.check_circle),
              label: 'accept'.i18n,
              onTap: () async {
                try {
                  // model.acceptIntroduction(from the person who is making the intro, to the person who they want to connect us to)
                  await model.acceptIntroduction(
                      contact.contactId.id, introduction.to.id);
                } catch (e, s) {
                  showErrorDialog(context,
                      e: e,
                      s: s,
                      des: 'introductions_error_description_accepting'.i18n);
                } finally {
                  await context.router.pop();
                  await context
                      .pushRoute(Conversation(contactId: introduction.to));
                }
              }),
          BottomModalItem(
              leading: const CAssetImage(path: ImagePaths.cancel),
              label: 'reject'.i18n,
              onTap: () => showAlertDialog(
                  context: context,
                  title:
                      CText('introductions_reject_title'.i18n, style: tsBody3),
                  content: CTextWrap('introductions_reject_content'.i18n,
                      style: tsBody1),
                  dismissText: 'cancel'.i18n,
                  agreeText: 'reject'.i18n,
                  agreeAction: () async {
                    try {
                      // model.rejectIntroduction(from the person who is making the intro, to the person who they want to connect us to)
                      await model.rejectIntroduction(
                          contact.contactId.id, introduction.to.id);
                    } catch (e, s) {
                      showErrorDialog(context,
                          e: e,
                          s: s,
                          des:
                              'introductions_error_description_rejecting'.i18n);
                    } finally {
                      await context.router.pop();
                    }
                  })),
        ]);
  }
}
