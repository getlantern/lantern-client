import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/contacts/generate_grouped_list.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';
import 'package:lantern/utils/iterable_extension.dart';
import 'package:lantern/utils/show_alert_dialog.dart';

class Introductions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();
    return BaseScreen(
      title: 'Introductions'.i18n,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Text(
              'Both parties must accept the introduction to message each other.  Introductions disappear after 7 days if no action is taken.'
                  .i18n,
              style: tsBaseScreenBodyText),
        ),
        Expanded(
          // TODO Connect Contacts need to update the subscription for this one
          child: model.contacts(builder: (context,
              Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
            var sortedRequests = _contacts.toList()
              ..sort((a, b) => sanitizeContactName(a.value)
                  .toLowerCase()
                  .toString()
                  .compareTo(
                      sanitizeContactName(b.value).toLowerCase().toString()));

            var groupedSortedRequests = sortedRequests.groupBy(
                (el) => sanitizeContactName(el.value)[0].toLowerCase());

            // TODO Connect Contacts - this controls the > animation, will leave for later
            var pendingRequest = true;

            return model.me((BuildContext context, Contact me, Widget? child) {
              final myContactId = me.contactId.id;
              return groupedContactListGenerator(
                groupedSortedList: groupedSortedRequests,
                separatorText: 'Introduced by '.i18n,
                leadingCallback: (Contact contact) => CustomBadge(
                  showBadge: true,
                  top: 25,
                  customBadge:
                      const Icon(Icons.timer, size: 16.0, color: Colors.black),
                  child: CircleAvatar(
                    backgroundColor: avatarBgColors[
                        generateUniqueColorIndex(contact.contactId.id)],
                    child: Text(
                        sanitizeContactName(contact)
                            .substring(0, 2)
                            .toUpperCase(),
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
                trailingCallback: (int index, Contact contact) => FittedBox(
                    child: pendingRequest
                        ? Row(
                            children: [
                              TextButton(
                                onPressed: () => showAlertDialog(
                                    context: context,
                                    title: Text('Reject Introduction?'.i18n,
                                        style: tsAlertDialogTitle),
                                    content: Text(
                                        'You will not be able to message this contact if you reject the introduction.'
                                            .i18n,
                                        style: tsAlertDialogBody),
                                    // naming is confusing here because we are using the Alert Dialog which by default has a [Reject vs Accept] field
                                    // but in this case it corresponds to [Cancel vs Reject]
                                    dismissText: 'Cancel'.i18n,
                                    agreeText: 'Reject'.i18n,
                                    agreeAction: () async {
                                      // (fromId, toId)
                                      await model.rejectIntroduction(
                                          'requesterId', myContactId);
                                    }),
                                child: Text('Reject'.i18n.toUpperCase(),
                                    style: tsAlertDialogButtonGrey),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // (fromId, toId)
                                  await model.acceptIntroduction(
                                      'requesterId', myContactId);
                                },
                                child: Text('Accept'.i18n.toUpperCase(),
                                    style: tsAlertDialogButtonPink),
                              )
                            ],
                          )
                        : const CustomAssetImage(
                            path: ImagePaths.keyboard_arrow_right_icon,
                            size: 24,
                          )),
              );
            });
          }),
        )
      ]),
    );
  }
}
