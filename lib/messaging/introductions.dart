import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/generic_list_item.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_badge.dart';
import 'package:lantern/utils/iterable_extension.dart';

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

            return groupedContactListGenerator(
                groupedSortedRequests,
                () => CustomBadge(
                      showBadge: true,
                      top: 25,
                      customBadge: const Icon(Icons.timer,
                          size: 16.0, color: Colors.black),
                      child: child,
                    ),
                FittedBox(
                    child: Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text('Reject'.i18n.toUpperCase(),
                          style: tsAlertDialogButtonGrey),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('Accept'.i18n.toUpperCase(),
                          style: tsAlertDialogButtonPink),
                    )
                  ],
                )),
                null);
          }),
        )
      ]),
    );
  }
}
