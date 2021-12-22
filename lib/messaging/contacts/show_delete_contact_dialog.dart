import '../messaging.dart';

void showDeleteContactDialog(
  BuildContext context,
  Contact contact,
) {
  showConfirmationDialog(
    context: context,
    iconPath: ImagePaths.delete,
    title: '${'delete_contact'.i18n}?',
    explanation: 'delete_info_description'.i18n,
    agreeText: 'delete_contact'.i18n,
    agreeAction: (_) async {
      context.loaderOverlay.show(widget: spinner);
      try {
        await messagingModel.deleteDirectContact(contact.contactId.id);
      } catch (e, s) {
        showErrorDialog(
          context,
          e: e,
          s: s,
          des: 'error_delete_contact'.i18n,
        );
      } finally {
        showSnackbar(
          context: context,
          content:
              'contact_was_deleted'.i18n.fill([contact.displayNameOrFallback]),
        );
        context.loaderOverlay.hide();
        context.router.popUntilRoot();
      }
      return true;
    },
  );
}
