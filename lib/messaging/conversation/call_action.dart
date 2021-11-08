import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/calls/call.dart';
import 'package:lantern/messaging/messaging.dart';

class CallAction extends StatelessWidget {
  final Contact contact;

  CallAction(this.contact) : super();

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return model.singleContact(
      context,
      contact,
      (context, contact, child) => IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: () => showBottomModal(
            context: context,
            title: CText(
                'call_contact'.i18n.fill([contact.displayNameOrFallback]),
                maxLines: 1,
                style: tsSubtitle1),
            children: [
              ListItemFactory.isBottomItem(
                leading: const CAssetImage(path: ImagePaths.phone),
                content: 'call'.i18n,
                onTap: () async {
                  Navigator.pop(context);
                  await context.pushRoute(
                    FullScreenDialogPage(
                        widget: Call(contact: contact, model: model)),
                  );
                },
              ),
              ListItemFactory.isBottomItem(
                leading: const CAssetImage(path: ImagePaths.cancel),
                content: 'cancel'.i18n,
                onTap: () => Navigator.pop(context),
              ),
            ]),
        icon: const CAssetImage(path: ImagePaths.phone),
      ),
    );
  }
}
