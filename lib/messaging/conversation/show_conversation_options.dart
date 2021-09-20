import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/protos_flutteronly/messaging.pb.dart';

import '../messaging_model.dart';
import 'show_disappearing_icon_dialog.dart';

void showConversationOptions(
    {required MessagingModel model,
    required BuildContext context,
    required Contact contact}) {
  return showBottomModal(context: context, children: [
    ListTile(
        leading: const CAssetImage(
          path: ImagePaths.disappearing_timer_icon,
          size: 24,
        ),
        title: Transform.translate(
          offset: const Offset(0, 0),
          child: CText('disappearing_messages'.i18n, style: tsTextField),
        ),
        onTap: () async => showDisappearingIconDialog(
              parentContext: context,
              bottomContext: context,
              contact: contact,
              model: model,
            )),
    const CBottomModalDivider(),
    ListTile(
      leading: const CAssetImage(
        path: ImagePaths.introduce_contact_icon,
        size: 16,
      ),
      contentPadding: const EdgeInsetsDirectional.only(
          top: 5, bottom: 5, start: 16, end: 16),
      title: Transform.translate(
          offset: const Offset(-14, 0),
          child: CText('introduce_contacts'.i18n, style: tsTextField)),
      onTap: () async => await bottomContext.pushRoute(const Introduce()),
    ),
    const CBottomModalDivider(),
    ListTile(
        leading: const CAssetImage(
          path: ImagePaths.trash_icon,
          size: 24,
        ),
        contentPadding: const EdgeInsetsDirectional.only(
            top: 5, bottom: 5, start: 16, end: 16),
        title: Transform.translate(
          offset: const Offset(-14, 0),
          child: TextOneLine(
              'delete_contact_name'.i18n.fill([contact.displayName]),
              style: tsTextField),
        ),
        onTap: () => showDialog<void>(
              context: bottomContext,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.delete),
                      ),
                      CText('delete_contact'.i18n.toUpperCase(),
                          style: tsBody3),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        CTextWrap('delete_contact_confirmation'.i18n,
                            style: tsBody1)
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
                            context.loaderOverlay.show(
                                widget: Center(
                              child: CircularProgressIndicator(
                                color: white,
                              ),
                            ));
                            try {
                              await model
                                  .deleteDirectContact(contact.contactId.id);
                            } catch (e, s) {
                              showErrorDialog(context,
                                  e: e, s: s, des: 'error_delete_contact'.i18n);
                            } finally {
                              context.loaderOverlay.hide();
                              // In order to be capable to return to the root screen, we need to pop the bottom sheet
                              // and then pop the root screen.
                              context.router.popUntilRoot();
                              parentContext.router.popUntilRoot();
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
            )),
  ]);
}
