// import 'package:lantern/features/messaging/calls/call.dart';
import 'package:lantern/features/messaging/contacts/add_contact_QR.dart';

import '../messaging.dart';

void showVerificationOptions({
  required BuildContext bottomModalContext,
  required Contact contact,
  bool showDismissNotification = false,
  Function? topBarAnimationCallback,
}) {
  void verificationUX() async {
    topBarAnimationCallback!();
    showSnackbar(
      context: bottomModalContext,
      duration: longAnimationDuration,
      content: 'verification_panel_success'
          .i18n
          .fill([contact.displayNameOrFallback]),
    );
  }

  return showBottomModal(
    context: bottomModalContext,
    title: CText(
      'verify_contact'.i18n.fill([contact.displayNameOrFallback]),
      maxLines: 1,
      style: tsSubtitle1,
    ),
    subtitle: CText(
      'verify_description'.i18n.fill([contact.displayNameOrFallback]),
      style: tsBody1.copiedWith(color: grey5),
    ),
    children: [
      messagingModel.me(
        (context, me, child) => ListItemFactory.bottomItem(
          icon: ImagePaths.qr_code_scanner,
          content: 'verify_in_person'.i18n,
          onTap: () async {
            await bottomModalContext.router.maybePop();
            await context.router
                .push(
              FullScreenDialogPage(widget: AddViaQR(me: me)),
            )
                .then((value) async {
              // * we just successfully verified someone via QR
              if (value != null) {
                verificationUX();
              }
            });
          },
          trailingArray: [const ContinueArrow()],
        ),
      ),
      // ListItemFactory.bottomItem(
      //   icon: ImagePaths.phone,
      //   content: 'verify_via_call'.i18n,
      //   onTap: () async {
      //     await bottomModalContext.router
      //         .popAndPush(
      //       FullScreenDialogPage(widget: Call(contact: contact)),
      //     )
      //         .then((value) async {
      //       // * we just successfully verified someone via a Call
      //       if (value == true) {
      //         verificationUX();
      //       }
      //     });
      //   },
      //   trailingArray: [const ContinueArrow()],
      // ),
      if (showDismissNotification)
        ListItemFactory.bottomItem(
          icon: ImagePaths.cancel,
          content: 'dismiss_notification'.i18n,
          onTap: () async {
            await messagingModel
                .dismissVerificationReminder(contact.contactId.id);
            await bottomModalContext.router.maybePop();
            CDialog(
              title: 'contact_verification'.i18n,
              iconPath: ImagePaths.verified_user,
              description: 'contact_verification_description'.i18n,
            ).show(bottomModalContext);
          },
        ),
    ],
  );
}
