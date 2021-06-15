import 'dart:io';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/button.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

class AddViaQR extends StatefulWidget {
  @override
  _AddViaQRState createState() => _AddViaQRState();
}

class _AddViaQRState extends State<AddViaQR> {
  final _qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? qrController;
  TextEditingController contactId = TextEditingController();
  TextEditingController displayName = TextEditingController();

  var scanning = false;
  var isVerified = false;

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
    qrController = controller;
    qrController?.pauseCamera();
    setState(() {
      scanning = false;
    });
    qrController?.scannedDataStream.listen((scanData) {
      try {
        var contact = Contact.fromJson(scanData.code);
        contactId.text = contact.contactId.id;
        displayName.text = contact.displayName;
        setState(() {
          isVerified = true;
        });
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
        title: 'QR Code'.i18n,
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code),
              tooltip: 'Your Contact Info'.i18n,
              onPressed: () {
                Navigator.restorablePushNamed(context, '/your_contact_info');
              }),
        ],
        body: model.me((BuildContext context, Contact me, Widget? child) {
          displayName.text = me.displayName;

          return SingleChildScrollView(
              child: Container(
            height: 100.h,
            color: Colors.black,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 50, bottom: 10),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        width: 200,
                        height: 200,
                        child: QRView(
                          key: _qrKey,
                          onQRViewCreated: _onQRViewCreated,
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        width: 200,
                        height: 200,
                        child: QrImage(
                          data: me.writeToJson(),
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                          version: QrVersions.auto,
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                        width: 70.w,
                        child: Text(
                          'To start a message with your friend, scan each others QR code.  This process will verify the security and end-to-end encryption of your conversation.'
                              .i18n,
                          style: const TextStyle(color: Colors.white),
                        )),
                  ),
                  // if (isVerified)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Button(
                            text: 'Continue to message'.i18n,
                            onPressed: () async {
                              context.loaderOverlay.show();
                              try {
                                await model.addOrUpdateDirectContact(
                                    contactId.value.text,
                                    displayName.value.text);
                                // Navigator.pushNamedAndRemoveUntil(
                                //     context, 'conversations', (r) => false);
                                Navigator.pop(context);
                              } finally {
                                context.loaderOverlay.hide();
                              }
                            },
                          ),
                        ]),
                  )
                ]),
          ));
        }));
  }
}
