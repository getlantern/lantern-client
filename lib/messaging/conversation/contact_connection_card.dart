import 'package:lantern/messaging/conversation/status_row.dart';
import 'package:lantern/messaging/messaging.dart';

class ContactConnectionCard extends StatelessWidget {
  final Contact contact;
  final bool inbound;
  final bool outbound;
  final StoredMessage message;

  ContactConnectionCard(
    this.contact,
    this.inbound,
    this.outbound,
    this.message,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MessagingModel>();
    final introduction = message.introduction;
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
                  hue: contact.hue, displayName: contact.displayName),
              title: CText(introduction.displayName,
                  style: tsBody3.copiedWith(
                      color: outbound ? outboundMsgColor : inboundMsgColor)),
              trailing: outbound
                  ? const SizedBox()
                  : FittedBox(
                      child: Row(
                        children: [
                          if (message.introduction.status ==
                              IntroductionDetails_IntroductionStatus.ACCEPTED)
                            Icon(Icons.check_circle,
                                color: outbound
                                    ? outboundMsgColor
                                    : inboundMsgColor),
                          Icon(
                              (message.introduction.status ==
                                      IntroductionDetails_IntroductionStatus
                                          .PENDING)
                                  ? Icons.info_outline_rounded
                                  : Icons.keyboard_arrow_right_outlined,
                              size: (message.introduction.status ==
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
                    message.introduction.status ==
                        IntroductionDetails_IntroductionStatus.PENDING) {
                  _showOptions(
                    context,
                    introduction,
                    model,
                    contact,
                  );
                }
                if (message.introduction.status ==
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
          children: [StatusRow(outbound, message)],
        )
      ],
    );
  }

  void _showOptions(BuildContext context, IntroductionDetails introduction,
      MessagingModel model, Contact contact) {
    return showBottomModal(
        context: context,
        title: CText(
            'introductions_title'.i18n.fill([introduction.displayName]),
            maxLines: 1,
            style: tsSubtitle1),
        subtitle: 'introductions_info'.i18n,
        children: [
          BottomModalItem(
              leading: const CAssetImage(path: ImagePaths.check_black),
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
              onTap: () => showConfirmationDialog(
                  context: context,
                  title: 'introductions_reject_title'.i18n,
                  explanation: 'introductions_reject_content'.i18n,
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
