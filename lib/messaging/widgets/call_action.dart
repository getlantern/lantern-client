import 'package:flutter/widgets.dart';
import 'package:lantern/messaging/calling/call.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/custom_asset_image.dart';

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
            builder: (context) => SizedBox(
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const CustomAssetImage(path: ImagePaths.phone_icon),
                    title: Text('Call'.i18n),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          PageRouteBuilder(
                              pageBuilder: (BuildContext context, _, __) =>
                                  Call(contact, model)));
                    },
                  ),
                ],
              ),
            ),
          );
        },
        icon: const CustomAssetImage(path: ImagePaths.phone_icon),
      ),
    );
  }
}
