import 'package:lantern/messaging/conversation/status_row.dart';
import 'package:lantern/messaging/introductions/introduction_extension.dart';
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
    final introduction = message.introduction;
    return Column(
      crossAxisAlignment: isLTR(context)
          ? outbound
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start
          : outbound
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              width:
                  outbound ? constraints.maxWidth * 0.6 : constraints.maxWidth,
              padding: const EdgeInsetsDirectional.only(
                start: 16.0,
                end: 16.0,
                top: 16.0,
                bottom: 4.0,
              ),
              child: GestureDetector(
                onTap: () async {
                  if (inbound && message.introduction.isPending()) {
                    _showOptions(
                      context,
                      introduction,
                      messagingModel,
                      contact,
                    );
                  }
                  if (message.introduction.isAccepted()) {
                    await context
                        .pushRoute(Conversation(contactId: introduction.to));
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomAvatar(
                      messengerId: message.introduction.to.id,
                      displayName: message.introduction.displayName,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 8.0,
                          end: 8.0,
                        ),
                        child: CText(
                          introduction.displayNameOrFallback,
                          overflow: TextOverflow.ellipsis,
                          style: tsBody3.copiedWith(
                            color:
                                outbound ? outboundMsgColor : inboundMsgColor,
                          ),
                        ),
                      ),
                    ),
                    if (!outbound)
                      Row(
                        children: [
                          if (message.introduction.isAccepted())
                            CAssetImage(
                              path: ImagePaths.check_black,
                              color:
                                  outbound ? outboundMsgColor : inboundMsgColor,
                              size: 20,
                            ),
                          mirrorLTR(
                            context: context,
                            child: CAssetImage(
                              path: (message.introduction.status ==
                                      IntroductionDetails_IntroductionStatus
                                          .PENDING)
                                  ? ImagePaths.info
                                  : ImagePaths.keyboard_arrow_right,
                              color:
                                  outbound ? outboundMsgColor : inboundMsgColor,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        Container(
          padding: const EdgeInsetsDirectional.only(start: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [StatusRow(outbound, message)],
          ),
        )
      ],
    );
  }

  void _showOptions(
    BuildContext context,
    IntroductionDetails introduction,
    MessagingModel model,
    Contact contact,
  ) {
    return showBottomModal(
      context: context,
      title: CText(
        'introductions_title'.i18n.fill([introduction.displayNameOrFallback]),
        maxLines: 1,
        style: tsSubtitle1,
      ),
      subtitle: CText(
        'introductions_info'.i18n,
        style: tsBody1.copiedWith(color: grey5),
      ),
      children: [
        ListItemFactory.bottomItem(
          icon: ImagePaths.check_black,
          content: 'accept'.i18n,
          onTap: () async {
            try {
              // model.acceptIntroduction(from the person who is making the intro, to the person who they want to connect us to)
              await model.acceptIntroduction(
                contact.contactId.id,
                introduction.to.id,
              );
            } catch (e, s) {
              CDialog.showError(
                context,
                error: e,
                stackTrace: s,
                description: 'introductions_error_description_accepting'.i18n,
              );
            } finally {
              await context.router.maybePop();
              await context.pushRoute(Conversation(contactId: introduction.to));
            }
          },
          trailingArray: [],
        ),
        ListItemFactory.bottomItem(
          icon: ImagePaths.cancel,
          content: 'reject'.i18n,
          onTap: () => CDialog(
            title: 'introduction_reject_title'.i18n,
            description: 'introduction_reject_content'.i18n,
            agreeText: 'reject'.i18n,
            agreeAction: () async {
              try {
                // model.rejectIntroduction(from the person who is making the intro, to the person who they want to connect us to)
                await model.rejectIntroduction(
                  contact.contactId.id,
                  introduction.to.id,
                );
                await context.router.maybePop();
                return true;
              } catch (e, s) {
                CDialog.showError(
                  context,
                  error: e,
                  stackTrace: s,
                  description: 'introductions_error_description_rejecting'.i18n,
                );
                return false;
              }
            },
          ).show(context),
          trailingArray: [],
        ),
      ],
    );
  }
}
