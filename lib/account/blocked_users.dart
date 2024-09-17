import 'package:lantern/messaging/messaging.dart';

@RoutePage(name: 'BlockedUsers')
class BlockedUsers extends StatelessWidget {
  BlockedUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'blocked_users'.i18n,
      body: messagingModel.contacts(
        builder: (
          context,
          Iterable<PathAndValue<Contact>> _contacts,
          Widget? child,
        ) {
          final blocked =
              _contacts.where((element) => element.value.blocked).toList();
          return blocked.isNotEmpty
              ? ListView(
                  children: [
                    ...blocked.map(
                      (blockedContact) => ListItemFactory.settingsItem(
                        content: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8.0),
                          child: CText(
                            blockedContact.value.displayNameOrFallback,
                            style: tsSubtitle1Short,
                          ),
                        ),
                        trailingArray: [
                          TextButton(
                            onPressed: () async => CDialog(
                              iconPath: ImagePaths.block,
                              title:
                                  '${'unblock'.i18n} ${blockedContact.value.displayNameOrFallback}?',
                              description: 'unblock_info_description'.i18n.fill(
                                [blockedContact.value.displayNameOrFallback],
                              ),
                              checkboxLabel: 'unblock_info_checkbox'.i18n,
                              agreeText: 'unblock'.i18n.toUpperCase(),
                              agreeAction: () async {
                                await messagingModel.unblockDirectContact(
                                  blockedContact.value.contactId.id,
                                );
                                showSnackbar(
                                  context: context,
                                  content: 'contact_was_unblocked'.i18n.fill([
                                    blockedContact.value.displayNameOrFallback
                                  ]),
                                );
                                return true;
                              },
                            ).show(context),
                            child: CText(
                              'unblock'.i18n.toUpperCase(),
                              style: tsButtonPink,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(24.0),
                    child: CText(
                      'no_blocked_users'.i18n,
                      style: tsSubtitle1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
        },
      ),
    );
  }
}
