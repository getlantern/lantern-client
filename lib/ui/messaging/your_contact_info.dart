import 'package:flutter/services.dart';
import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class YourContactInfo extends StatefulWidget {
  @override
  _YourContactInfoState createState() => _YourContactInfoState();
}

class _YourContactInfoState extends State<YourContactInfo> {
  TextEditingController displayName = TextEditingController();
  FocusNode displayNameFocus;
  var editing = false;

  @override
  void initState() {
    super.initState();
    displayNameFocus = FocusNode();
  }

  @override
  void dispose() {
    displayNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    if (editing) {
      displayNameFocus.requestFocus();
    } else {
      displayNameFocus.unfocus();
    }

    return BaseScreen(
      title: 'Your Contact Info'.i18n,
      body: model.me((BuildContext context, Contact me, Widget child) {
        displayName.text = me.displayName;

        void copyToClipboard() {
          Clipboard.setData(new ClipboardData(text: me.id));
        }

        return Column(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 64, right: 64, top: 32, bottom: 32),
                      child: QrImage(
                        data: me.writeToJson(),
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(children: [
                      Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 4),
                          child: Text(
                              "Messenger Display Name (How Others See You)"
                                      .i18n
                                      .toUpperCase() +
                                  ":",
                              style:
                                  tsSubTitle(context).copyWith(fontSize: 12))),
                      ListTile(
                        title: TextFormField(
                            controller: displayName,
                            focusNode: displayNameFocus,
                            decoration: InputDecoration(
                              icon: Icon(Icons.perm_identity),
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            )),
                        tileColor: Colors.black12,
                        trailing: TextButton(
                            child: editing
                                ? Text('Save'.i18n)
                                : Text('Change'.i18n),
                            onPressed: () {
                              if (editing) {
                                var text = displayName.value.text;
                                model.setMyDisplayName(text);
                                setState(() {
                                  editing = false;
                                });
                              } else {
                                setState(() {
                                  editing = true;
                                });
                              }
                            }),
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(left: 16, bottom: 4, top: 32),
                          child: Text(
                              "Messenger ID (How Others Contact You)"
                                      .i18n
                                      .toUpperCase() +
                                  ":",
                              style:
                                  tsSubTitle(context).copyWith(fontSize: 12))),
                      ListTile(
                        leading: Icon(Icons.vpn_key_rounded),
                        title: Text(me.id),
                        tileColor: Colors.black12,
                        onTap: copyToClipboard,
                      ),
                    ]),
                  ),
                ]),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            OutlinedButton(
              child: Text('Copy ID'.i18n),
              onPressed: copyToClipboard,
            ),
            OutlinedButton(
                child: Text('Share'.i18n),
                onPressed: () {
                  Share.share('Join me on Lantern Messenger.\n\nMy ID is: ${me.id}');
                }),
          ])
        ]);
      }),
    );
  }
}
