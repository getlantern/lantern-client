import 'package:lantern/common/common.dart';

import '../messaging.dart';

void showBlockContactDialog(
  BuildContext context,
  Contact contact,
) async {
  var confirmBlock = false;
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
                contentPadding: const EdgeInsetsDirectional.all(24.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!contact.blocked)
                      const Padding(
                        padding: EdgeInsetsDirectional.all(8.0),
                        child: CAssetImage(path: ImagePaths.block),
                      ),
                    CText(
                        contact.blocked
                            ? '${'unblock'.i18n} ${contact.displayNameOrFallback}?'
                            : '${'block'.i18n} ${contact.displayNameOrFallback}?',
                        style: tsSubtitle1),
                  ],
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsetsDirectional.all(24),
                        child: CText(
                            contact.blocked
                                ? 'unblock_info_description'
                                    .i18n
                                    .fill([contact.displayNameOrFallback])
                                : 'block_info_description'.i18n,
                            style: tsBody1.copiedWith(color: grey5)),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 8.0, end: 8.0),
                        child: Row(
                          children: [
                            Checkbox(
                                checkColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                    side: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2.0))),
                                fillColor: MaterialStateProperty.resolveWith(
                                    (states) =>
                                        getCheckboxFillColor(black, states)),
                                value: confirmBlock,
                                onChanged: (bool? value) {
                                  setState(() => confirmBlock = value!);
                                }),
                            Expanded(
                              child: CText(
                                  contact.blocked
                                      ? 'unblock_info_checkbox'.i18n
                                      : 'block_info_checkbox'.i18n,
                                  style: tsBody1),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () async => context.router.pop(),
                        child: CText('cancel'.i18n.toUpperCase(),
                            style: tsButtonGrey),
                      ),
                      const SizedBox(width: 15),
                      TextButton(
                        onPressed: () async {
                          if (confirmBlock) {
                            contact.blocked
                                ? await messagingModel
                                    .unblockDirectContact(contact.contactId.id)
                                : await messagingModel
                                    .blockDirectContact(contact.contactId.id);
                            context.router.popUntilRoot();
                            showSnackbar(
                                context: context,
                                content: contact.blocked
                                    ? 'contact_was_unblocked'
                                        .i18n
                                        .fill([contact.displayNameOrFallback])
                                    : 'contact_was_blocked'
                                        .i18n
                                        .fill([contact.displayNameOrFallback]));
                          }
                        },
                        child: CText(
                            contact.blocked
                                ? 'unblock'.i18n.toUpperCase()
                                : 'block'.i18n.toUpperCase(),
                            style: confirmBlock ? tsButtonPink : tsButtonGrey),
                      )
                    ],
                  )
                ],
              ));
    },
  );
}
