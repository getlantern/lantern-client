import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/package_store.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

class YourContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'Your Contact Info'.i18n,
      body: model.myContactId(
          (BuildContext context, String myContactId, Widget child) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(left: 64, right: 64, top: 32, bottom: 32),
            child: QrImage(
              data: myContactId,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              version: QrVersions.auto,
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                  "Messenger Display Name (How Others See You)"
                          .i18n
                          .toUpperCase() +
                      ":",
                  style: tsSubTitle(context).copyWith(fontSize: 12))),
          ListTile(
            leading: Icon(Icons.perm_identity),
            title: Text("My Display Name Here TBD"),
            trailing: TextButton(child: Text("Change".i18n)),
            tileColor: Colors.black12,
          ),
          Padding(
              padding: EdgeInsets.only(left: 16, bottom: 4, top: 32),
              child: Text(
                  "Messenger ID (How Others Contact You)".i18n.toUpperCase() +
                      ":",
                  style: tsSubTitle(context).copyWith(fontSize: 12))),
          ListTile(
            leading: Icon(Icons.vpn_key_rounded),
            title: Text(myContactId),
            tileColor: Colors.black12,
            onTap: () {
              Clipboard.setData(new ClipboardData(text: myContactId));
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('contact id copied to clipboard'.i18n)));
            },
          )
        ]);
      }),
    );
  }
}
