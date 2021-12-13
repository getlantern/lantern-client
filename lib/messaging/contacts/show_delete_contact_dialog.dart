import '../messaging.dart';

void showDeleteContactDialog(
  BuildContext context,
  Contact contact,
) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
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
            const Padding(
              padding: EdgeInsetsDirectional.all(8.0),
              child: CAssetImage(path: ImagePaths.delete),
            ),
            CText('${'delete_contact'.i18n}?', style: tsBody3),
          ],
        ),
        content: CText('delete_info_description'.i18n, style: tsBody1),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async => context.router.pop(),
                child: CText('cancel'.i18n.toUpperCase(), style: tsButtonGrey),
              ),
              const SizedBox(width: 15),
              TextButton(
                onPressed: () async {
                  context.loaderOverlay.show(widget: spinner);
                  try {
                    await messagingModel
                        .deleteDirectContact(contact.contactId.id);
                  } catch (e, s) {
                    showErrorDialog(context,
                        e: e, s: s, des: 'error_delete_contact'.i18n);
                  } finally {
                    showSnackbar(
                        context: context,
                        content: 'contact_was_deleted'
                            .i18n
                            .fill([contact.displayNameOrFallback]));
                    context.loaderOverlay.hide();
                    context.router.popUntilRoot();
                  }
                },
                child: CText('delete_contact'.i18n.toUpperCase(),
                    style: tsButtonPink),
              )
            ],
          )
        ],
      );
    },
  );
}
