import 'dart:io';

import 'package:lantern/model/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AddContact extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final _qrKey = GlobalKey(debugLabel: 'QR');
  final _formKey = GlobalKey<FormState>(debugLabel: 'Contact Form');

  QRViewController qrController;
  TextEditingController contactId = TextEditingController();
  TextEditingController displayName = TextEditingController();

  var scanning = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrController?.pauseCamera();
      setState(() {
        scanning = false;
      });
    } else if (Platform.isIOS) {
      qrController?.resumeCamera();
      setState(() {
        scanning = true;
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.qrController = controller;
    qrController?.pauseCamera();
    setState(() {
      scanning = false;
    });
    qrController?.scannedDataStream?.listen((scanData) {
      try {
        var contact = Contact.fromJson(scanData.code);
        contactId.text = contact.id;
        displayName.text = contact.displayName;
      } finally {
        qrController?.pauseCamera();
        setState(() {
          scanning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(
      title: 'Add Contact'.i18n,
      actions: [
        IconButton(
            icon: Icon(Icons.qr_code),
            tooltip: "Your Contact Info".i18n,
            onPressed: () {
              Navigator.restorablePushNamed(context, 'your_contact_info');
            }),
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                      child: Text(scanning
                          ? 'Stop Scanning'.i18n
                          : 'Scan QR Code'.i18n),
                      onPressed: () async {
                        if (scanning) {
                          qrController.pauseCamera();
                          setState(() {
                            scanning = false;
                          });
                        } else {
                          qrController.resumeCamera();
                          setState(() {
                            scanning = true;
                          });
                        }
                      }),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    controller: contactId,
                    minLines: 2,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Messenger ID'.i18n,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value.length != 52) {
                        return 'Please enter a 52 digit Messenger ID'.i18n;
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextFormField(
                    controller: displayName,
                    decoration: InputDecoration(
                      labelText: 'Name'.i18n,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a name for this contact'.i18n;
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            child: Text('Continue'.i18n),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                context.showLoaderOverlay();
                                try {
                                  await model.addOrUpdateDirectContact(
                                      contactId.value.text,
                                      displayName.value.text);
                                  // Navigator.pushNamedAndRemoveUntil(
                                  //     context, 'conversations', (r) => false);
                                  Navigator.pop(context);
                                } finally {
                                  context.hideLoaderOverlay();
                                }
                              }
                            }),
                      ]),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
