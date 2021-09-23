import 'package:lantern/common/common.dart';

void showConfirmationDialog() {
  showAlertDialog(
    context: context,
    key: const ValueKey('deleteForMeDialog'),
    barrierDismissible: true,
    content: SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          CText('delete_for_me_explanation'.i18n, style: tsBody1)
        ],
      ),
    ),
    title: CText('delete_for_me'.i18n, style: tsSubtitle1),
    agreeAction: () => model.deleteLocally(message),
    agreeText: 'delete'.i18n,
  );
}
