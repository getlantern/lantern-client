// import 'package:lantern/features/messaging/calls/call.dart';
import 'package:lantern/features/messaging/messaging.dart';

class CallAction extends StatelessWidget {
  final Contact contact;

  CallAction(this.contact) : super();

  @override
  Widget build(BuildContext context) {
    return messagingModel.singleContact(
      contact,
      (context, contact, child) => IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: () => showBottomModal(
          context: context,
          title: CText(
            'call_contact'.i18n.fill([contact.displayNameOrFallback]),
            maxLines: 1,
            style: tsSubtitle1,
          ),
          children: [
            // ListItemFactory.bottomItem(
            //   icon: ImagePaths.phone,
            //   content: 'call'.i18n,
            //   onTap: () async {
            //     Navigator.pop(context);
            //     await context.pushRoute(
            //       FullScreenDialogPage(widget: Call(contact: contact)),
            //     );
            //   },
            // ),
            ListItemFactory.bottomItem(
              icon: ImagePaths.cancel,
              content: 'cancel'.i18n,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        icon: const CAssetImage(path: ImagePaths.phone),
      ),
    );
  }
}
