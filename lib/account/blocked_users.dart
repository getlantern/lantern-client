import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/contacts/show_block_contact_dialog.dart';
import 'package:lantern/messaging/messaging.dart';

class BlockedUsers extends StatelessWidget {
  BlockedUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
        title: 'blocked_users'.i18n,
        body: model.contacts(builder: (context,
            Iterable<PathAndValue<Contact>> _contacts, Widget? child) {
          final blocked =
              _contacts.where((element) => element.value.blocked).toList();
          return blocked.isNotEmpty
              ? ListView(
                  children: [
                    ...blocked.map((blockedContact) =>
                        ListItemFactory.settingsItem(
                            content: Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 8.0),
                              child: CText(
                                blockedContact.value.displayNameOrFallback,
                                style: tsSubtitle1Short,
                              ),
                            ),
                            trailingArray: [
                              TextButton(
                                onPressed: () async => showBlockContactDialog(
                                  context,
                                  blockedContact.value,
                                  model,
                                ),
                                child: CText(
                                  'unblock'.i18n.toUpperCase(),
                                  style: tsButtonPink,
                                ),
                              )
                            ]))
                  ],
                )
              : Center(
                  child: Padding(
                  padding: const EdgeInsetsDirectional.all(24.0),
                  child: CText('no_blocked_users'.i18n,
                      style: tsSubtitle1, textAlign: TextAlign.center),
                ));
        }));
  }
}
