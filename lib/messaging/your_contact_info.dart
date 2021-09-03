import 'package:flutter/services.dart';
import 'package:lantern/messaging/messaging_model.dart';
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
  late FocusNode displayNameFocus;
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
      title: Text(
        'Your Contact Info'.i18n,
        style: tsTitleAppbar,
      ),
      body: model.me((BuildContext context, Contact me, Widget? child) {
        displayName.text = me.displayName;

        void copyToClipboard() {
          Clipboard.setData(ClipboardData(text: me.contactId.id));
        }

        return Column(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 64, right: 64, top: 32, bottom: 32),
                      child: QrImage(
                        data: '${me.contactId.id}|${me.displayName}',
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Text(
                              'Messenger Display Name (How Others See You)'
                                      .i18n
                                      .toUpperCase() +
                                  ':',
                              style:
                                  tsSubTitle(context)?.copyWith(fontSize: 12))),
                      !editing
                          ? ListTile(
                              leading: const Icon(Icons.perm_identity),
                              title: Text(displayName.value.text),
                              tileColor: Colors.black12,
                              trailing: TextButton(
                                onPressed: () {
                                  setState(() {
                                    editing = true;
                                  });
                                },
                                child: Text('Change'.i18n,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                            )
                          : ListTile(
                              title: TextFormField(
                                  controller: displayName,
                                  focusNode: displayNameFocus,
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.perm_identity),
                                    enabledBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  )),
                              tileColor: Colors.white,
                              trailing: TextButton(
                                onPressed: () {
                                  var text = displayName.value.text;
                                  model.setMyDisplayName(text);
                                  setState(() {
                                    editing = false;
                                  });
                                },
                                child: Text('Save'.i18n,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 16, bottom: 4, top: 32),
                          child: Text(
                              'Messenger ID (How Others Contact You)'
                                      .i18n
                                      .toUpperCase() +
                                  ':',
                              style:
                                  tsSubTitle(context)?.copyWith(fontSize: 12))),
                      ListTile(
                        leading: const Icon(Icons.vpn_key_rounded),
                        title: Text(me.contactId.id),
                        tileColor: Colors.black12,
                        onTap: copyToClipboard,
                      ),
                    ]),
                  ),
                ]),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            OutlinedButton(
              onPressed: copyToClipboard,
              child: Text('Copy ID'.i18n),
            ),
            OutlinedButton(
              onPressed: () {
                Share.share(
                    'Join me on Lantern Messenger.\n\nMy ID is: ${me.contactId.id}');
              },
              child: Text('Share'.i18n),
            ),
          ])
        ]);
      }),
    );
  }
}
