import 'package:lantern/features/messaging/introductions/introduction_extension.dart';
import 'package:lantern/features/messaging/messaging.dart';

@RoutePage(name: 'Introductions')
class Introductions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'introductions'.i18n,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsetsDirectional.only(top: 16.0, bottom: 16.0),
            child: CText('introductions_info'.i18n, style: tsBody1),
          ),
          Expanded(
            child: messagingModel.bestIntroductions(
              builder: (
                bestIntrosContext,
                Iterable<PathAndValue<StoredMessage>> introductions,
                Widget? child,
              ) {
                // group by the contactId of the user who made the introduction
                // these are pointers to StoredMessages, they won't listen to an update to the value of the StoredMessage itself
                final groupedIntroductions = introductions
                    .getPending()
                    .groupBy((intro) => intro.value.contactId);

                if (groupedIntroductions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(24.0),
                      child: CText(
                        'no_introductions'.i18n,
                        style: tsBody1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: groupedIntroductions.length,
                  itemBuilder: (listContext, index) {
                    var introductorContactId =
                        groupedIntroductions.keys.elementAt(index);
                    var introductionsPerIntroductor =
                        groupedIntroductions.values.elementAt(index);
                    // match the <ContactId> to the <Contact> of the user who made the introduction
                    return Container(
                      child: messagingModel.singleContactById(
                        introductorContactId,
                        (singleContactContext, introductor, child) => Column(
                          key: const ValueKey('introductions_list'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 4,
                              ),
                              child: CText(
                                'introduced'.i18n.fill([
                                  introductor.displayNameOrFallback
                                ]).toUpperCase(),
                                maxLines: 1,
                                style: tsOverline,
                              ),
                            ),
                            const CDivider(),
                            ...introductionsPerIntroductor.map(
                              // need to subscribe to StoredMessage via model.message() to receive updates about status
                              (introMessage) => messagingModel.message(
                                singleContactContext,
                                introMessage,
                                (
                                  messageContext,
                                  value,
                                  child,
                                ) =>
                                    (value.introduction.isPending())
                                        ? ListItemFactory.messagingItem(
                                            content: value.introduction
                                                .displayNameOrFallback,
                                            leading: CBadge(
                                              showBadge: true,
                                              top: 25,
                                              // Render the countdown timer for the introduction's expiry
                                              // the backend is taking care of assigning a different duration to these messages
                                              customBadge: CountdownStopwatch(
                                                startMillis:
                                                    value.disappearAt.toInt(),
                                                endMillis:
                                                    value.disappearAt.toInt(),
                                                color: black,
                                              ),
                                              child: CustomAvatar(
                                                messengerId:
                                                    value.introduction.to.id,
                                                displayName: value.introduction
                                                    .displayNameOrFallback,
                                              ),
                                            ),
                                            trailingArray: [
                                              //* REJECT INTRO
                                              TextButton(
                                                onPressed: () => CDialog(
                                                  title:
                                                      'introduction_reject_title'
                                                          .i18n,
                                                  description:
                                                      'introduction_reject_content'
                                                          .i18n,
                                                  // variable names are a bit confusing here: we are using the AlertDialog which by default has a [Reject vs Accept] field, but in this case these correspond to [Cancel vs Reject]
                                                  agreeText: 'reject'.i18n,
                                                  agreeAction: () async {
                                                    try {
                                                      // model.rejectIntroduction(from the person who is making the intro, to the person who they want to connect us to)
                                                      await messagingModel
                                                          .rejectIntroduction(
                                                        introductor
                                                            .contactId.id,
                                                        value
                                                            .introduction.to.id,
                                                      );
                                                      return true;
                                                    } catch (e, s) {
                                                      CDialog.showError(
                                                        context,
                                                        error: e,
                                                        stackTrace: s,
                                                        description:
                                                            'introductions_error_description_rejecting'
                                                                .i18n,
                                                      );
                                                      return false;
                                                    }
                                                  },
                                                ).show(context),
                                                child: CText(
                                                  'reject'.i18n.toUpperCase(),
                                                  style: tsButtonGrey,
                                                ),
                                              ),
                                              //* ACCEPT INTRO
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    // model.acceptIntroduction(from the person who is making the intro, to the person who they want to connect us to)
                                                    await messagingModel
                                                        .acceptIntroduction(
                                                      introductor.contactId.id,
                                                      value.introduction.to.id,
                                                    );
                                                  } catch (e, s) {
                                                    CDialog.showError(
                                                      context,
                                                      error: e,
                                                      stackTrace: s,
                                                      description:
                                                          'introductions_error_description_accepting'
                                                              .i18n,
                                                    );
                                                  } finally {
                                                    showSnackbar(
                                                      context: context,
                                                      content:
                                                          'introduction_approved'
                                                              .i18n
                                                              .fill([
                                                        value.introduction
                                                            .displayNameOrFallback
                                                      ]),
                                                      duration:
                                                          longAnimationDuration,
                                                      action: SnackBarAction(
                                                        textColor: yellow4,
                                                        label: 'start_chat'
                                                            .i18n
                                                            .toUpperCase(),
                                                        onPressed: () async {
                                                          await context.router
                                                              .push(
                                                            Conversation(
                                                              contactId: value
                                                                  .introduction
                                                                  .to,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: CText(
                                                  'accept'.i18n.toUpperCase(),
                                                  style: tsButtonPink,
                                                ),
                                              )
                                            ],
                                          )
                                        : Container(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
