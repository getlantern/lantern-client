import 'package:lantern/messaging/messaging.dart';

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
                            onPressed: () async => showInfoDialog(
                              context,
                              assetPath: ImagePaths.block,
                              title: blockedContact.value.blocked
                                  ? '${'unblock'.i18n} ${blockedContact.value.displayNameOrFallback}?'
                                  : '${'block'.i18n} ${blockedContact.value.displayNameOrFallback}?',
                              des: blockedContact.value.blocked
                                  ? 'unblock_info_description'.i18n.fill([
                                      blockedContact.value.displayNameOrFallback
                                    ])
                                  : 'block_info_description'.i18n,
                              checkboxText: blockedContact.value.blocked
                                  ? 'unblock_info_checkbox'.i18n
                                  : 'block_info_checkbox'.i18n,
                              cancelButtonText: 'cancel'.i18n,
                              confirmButtonText: blockedContact.value.blocked
                                  ? 'unblock'.i18n.toUpperCase()
                                  : 'block'.i18n.toUpperCase(),
                              confirmCheckboxAction: () async {
                                blockedContact.value.blocked
                                    ? await messagingModel.unblockDirectContact(
                                        blockedContact.value.contactId.id,
                                      )
                                    : await messagingModel.blockDirectContact(
                                        blockedContact.value.contactId.id,
                                      );
                                context.router.popUntilRoot();
                                showSnackbar(
                                  context: context,
                                  content: blockedContact.value.blocked
                                      ? 'contact_was_unblocked'.i18n.fill([
                                          blockedContact
                                              .value.displayNameOrFallback
                                        ])
                                      : 'contact_was_blocked'.i18n.fill([
                                          blockedContact
                                              .value.displayNameOrFallback
                                        ]),
                                );
                              },
                            ),
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
