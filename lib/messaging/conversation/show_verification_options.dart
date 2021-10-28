import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/calls/call.dart';
import 'package:lantern/messaging/contacts/add_contact_QR.dart';
import '../messaging.dart';

void showVerificationOptions({
  required MessagingModel model,
  required BuildContext bottomModalContext,
  required Contact contact,
}) {
  return showBottomModal(
      context: bottomModalContext,
      title: CText('verify_contact'.i18n.fill([contact.displayNameOrFallback]),
          maxLines: 1, style: tsSubtitle1),
      subtitle: CText(
          'verify_description'.i18n.fill([contact.displayNameOrFallback]),
          style: tsBody1.copiedWith(color: grey5)),
      children: [
        model.me((context, me, child) => BottomModalItem(
              leading: const CAssetImage(path: ImagePaths.qr_code_scanner),
              label: 'verify_in_person'.i18n,
              onTap: () async {
                await bottomModalContext.router.pop();
                await context
                    .pushRoute(
                  FullScreenDialogPage(widget: AddViaQR(me: me)),
                )
                    .then((value) {
                  // * we just successfully verified someone via QR scanning
                  if (value != null) {
                    // TODO: show animation
                    showSnackbar(
                        context: context,
                        content: 'verification_panel_success'
                            .i18n
                            .fill([contact.displayNameOrFallback]));
                  }
                });
              },
              trailing: const CAssetImage(
                path: ImagePaths.keyboard_arrow_right,
              ),
            )),
        BottomModalItem(
          leading: const CAssetImage(path: ImagePaths.phone),
          label: 'verify_via_call'.i18n,
          onTap: () async {
            await bottomModalContext.router.pop();
            await bottomModalContext
                .pushRoute(
              FullScreenDialogPage(
                  widget: Call(contact: contact, model: model)),
            )
                .then((value) {
              // * we just successfully verified someone via a Call
              if (value != null) {
                // TODO: show animation
                showSnackbar(
                    context: bottomModalContext,
                    content: 'verification_panel_success'
                        .i18n
                        .fill([contact.displayNameOrFallback]));
              }
            });
          },
          trailing: const CAssetImage(
            path: ImagePaths.keyboard_arrow_right,
          ),
        ),
        BottomModalItem(
          leading: const CAssetImage(path: ImagePaths.cancel),
          label: 'dismiss_notification'.i18n,
          onTap: () async {
            await bottomModalContext.router.pop();
            showInfoDialog(bottomModalContext,
                title: 'contact_verification'.i18n,
                assetPath: ImagePaths.verified_user,
                des: 'contact_verification_description'.i18n,
                buttonText: 'info_dialog_confirm'.i18n);
          },
        ),
      ]);
}
