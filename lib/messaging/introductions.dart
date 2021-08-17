import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/contact_list_item.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';
import 'package:lantern/utils/iterable_extension.dart';
import 'package:lantern/utils/show_alert_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/utils/introduction_extension.dart';
import 'package:lantern/utils/stored_message_extension.dart';

class Introductions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
        title: 'Introductions'.i18n,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Text(
                    'Both parties must accept the introduction to message each other.  Introductions disappear after 7 days if no action is taken.'
                        .i18n,
                    style: tsBaseScreenBodyText),
              ),
              Expanded(child: model.introductionsToContact(builder: (context,
                  Iterable<PathAndValue<StoredMessage>> introductions,
                  Widget? child) {
                // group by the contactId of the user who made the introduction
                final groupedIntroductions = introductions
                    .getPending()
                    .groupBy((intro) => intro.value.contactId);
                // if we want to be even more economical we can mod GroupedListGenerator to accept Map<String, List<PathAndValue<StoredMessage>>>? as well
                return ListView.builder(
                  itemCount: groupedIntroductions.length,
                  itemBuilder: (context, index) {
                    var introductorContactId =
                        groupedIntroductions.keys.elementAt(index);
                    var introductionsPerIntroductor =
                        groupedIntroductions.values.elementAt(index);
                    // match the <ContactId> to the <Contact> of the user who made the introduction
                    return Container(
                      child: model.singleContactById(
                          context,
                          introductorContactId,
                          (context, introductor, child) => Column(children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 16.0, 0, 4.0),
                                      child: Text(
                                        'Introduced by ' +
                                            introductor.displayName
                                                .toUpperCase(),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 1.0, color: grey3),
                                ...introductionsPerIntroductor.map((intro) =>
                                    ContactListItem(
                                        contact: introductor,
                                        index: index,
                                        title: sanitizeContactName(intro
                                            .value.introduction.displayName),
                                        leading: CustomBadge(
                                          showBadge: true,
                                          top: 25,
                                          // Render the countdown timer for the introduction's expiry
                                          // the backend is taking care of assigning a different duration to these messages
                                          customBadge: TweenAnimationBuilder<
                                                  int>(
                                              key: Key(
                                                  'tween_${intro.value.id}'),
                                              tween: IntTween(
                                                  begin: DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                  end: intro.value.disappearAt
                                                      .toInt()),
                                              duration: Duration(
                                                  milliseconds: intro
                                                          .value.disappearAt
                                                          .toInt() -
                                                      intro.value
                                                          .firstViewedAt // we start counting from when the message containing the introduction is seen
                                                          .toInt()),
                                              curve: Curves.linear,
                                              builder: (BuildContext context,
                                                  int time, Widget? child) {
                                                var index = intro.value
                                                    .position(
                                                        segments: intro
                                                            .value
                                                            .segments(
                                                                iterations:
                                                                    12));
                                                return CustomAssetImage(
                                                    path: ImagePaths
                                                        .countdownPaths[index],
                                                    size: 12,
                                                    color: Colors.black);
                                              }),
                                          child: CircleAvatar(
                                            backgroundColor: avatarBgColors[
                                                generateUniqueColorIndex(intro
                                                    .value
                                                    .introduction
                                                    .displayName)],
                                            child: Text(
                                                sanitizeContactName(intro
                                                        .value
                                                        .introduction
                                                        .displayName)
                                                    .substring(0, 2)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ),
                                        trailing: FittedBox(
                                            child: Row(
                                          children: [
                                            TextButton(
                                              onPressed: () => showAlertDialog(
                                                  context: context,
                                                  title: Text(
                                                      'Reject Introduction?'
                                                          .i18n,
                                                      style:
                                                          tsAlertDialogTitle),
                                                  content: Text(
                                                      'You will not be able to message this contact if you reject the introduction.'
                                                          .i18n,
                                                      style: tsAlertDialogBody),
                                                  // variable names are a bit confusing here: we are using the AlertDialog which by default has a [Reject vs Accept] field, but in this case these correspond to [Cancel vs Reject]
                                                  dismissText: 'Cancel'.i18n,
                                                  agreeText: 'Reject'.i18n,
                                                  agreeAction: () async {
                                                    try {
                                                      // model.rejectIntroduction(from the person who is making the intro, to the person who they want to connect us to)
                                                      await model
                                                          .rejectIntroduction(
                                                              introductor
                                                                  .contactId.id,
                                                              intro
                                                                  .value
                                                                  .introduction
                                                                  .to
                                                                  .id);
                                                    } catch (e) {
                                                      showInfoDialog(context,
                                                          title: 'Error'.i18n,
                                                          des:
                                                              'Something went wrong while rejecting this connect request.'
                                                                  .i18n,
                                                          icon: ImagePaths
                                                              .alert_icon,
                                                          buttonText:
                                                              'OK'.i18n);
                                                    } finally {
                                                      await context.router
                                                          .pop();
                                                    }
                                                  }),
                                              child: Text(
                                                  'Reject'.i18n.toUpperCase(),
                                                  style:
                                                      tsAlertDialogButtonGrey),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  // model.acceptIntroduction(from the person who is making the intro, to the person who they want to connect us to)
                                                  await model
                                                      .acceptIntroduction(
                                                          introductor
                                                              .contactId.id,
                                                          intro
                                                              .value
                                                              .introduction
                                                              .to
                                                              .id);
                                                } catch (e) {
                                                  showInfoDialog(context,
                                                      title: 'Error'.i18n,
                                                      des:
                                                          'Something went wrong while accepting this connect request.'
                                                              .i18n,
                                                      icon:
                                                          ImagePaths.alert_icon,
                                                      buttonText: 'OK'.i18n);
                                                } finally {
                                                  await context.router.pop();
                                                }
                                              },
                                              child: Text(
                                                  'Accept'.i18n.toUpperCase(),
                                                  style:
                                                      tsAlertDialogButtonPink),
                                            )
                                          ],
                                        )))),
                              ])),
                    );
                  },
                );
              })),
            ]));
  }
}
