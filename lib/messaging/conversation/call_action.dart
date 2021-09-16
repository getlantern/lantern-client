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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0))),
            builder: (context) => Wrap(
              children: [
                ListTile(
                  leading: const CAssetImage(path: ImagePaths.phone_icon),
                  title: CText('call'.i18n, style: tsBody16),
                  onTap: () async {
                    Navigator.pop(context);
                    await context.pushRoute(
                      FullScreenDialogPage(
                          widget: Call(contact: contact, model: model)),
                    );
                  },
                ),
                ListTile(
                  leading: const CAssetImage(path: ImagePaths.cancel_icon),
                  title: CText('cancel'.i18n, style: tsBody16),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
        icon: const CAssetImage(path: ImagePaths.phone_icon),
      ),
    );
  }
}
