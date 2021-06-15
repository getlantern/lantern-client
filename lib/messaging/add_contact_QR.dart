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

  bool scanning = false;
  bool contactIsVerified = false;
  bool contactVerifiedMe = false;
  String? contactId;
  String? displayName;

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

  void _onQRViewCreated(QRViewController controller, MessagingModel model) {
    qrController = controller;
    qrController?.pauseCamera();
    setState(() {
      scanning = false;
    });
    qrController?.scannedDataStream.listen((scanData) async {
      try {
        // TODO: This should return the displayName in addition to contactId
        var contact = Contact.fromJson(scanData.code);
        setState(() async {
          contactIsVerified = await model.verifyContact(contact);
          contactVerifiedMe = await model.getMyVerificationStatus(contact);
          contactId = contact.contactId.id;
          displayName = contact.displayName;
        });
      } finally {
        await qrController?.pauseCamera();
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
          return SingleChildScrollView(
              child: Container(
            height: 100.h,
            width: 100.w,
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            QRView(
                              key: _qrKey,
                              onQRViewCreated: (controller) =>
                                  _onQRViewCreated(controller, model),
                            ),
                            if (contactIsVerified)
                              const Icon(
                                Icons.check_circle_outline_outlined,
                                size: 200,
                                color: Colors.white,
                              ),
                          ],
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
                        height: 225,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  QrImage(
                                    data: me.writeToJson(),
                                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                                    version: QrVersions.auto,
                                  ),
                                  if (contactVerifiedMe)
                                    const Icon(
                                      Icons.check_circle_outline_outlined,
                                      size: 200,
                                      color: Colors.white,
                                    ),
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(me.displayName,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ))),
                            ]),
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
                  if (contactIsVerified | contactVerifiedMe)
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
                                  final isFullyVerified =
                                      contactIsVerified && contactVerifiedMe;
                                  await model.addOrUpdateDirectContact(
                                      contactId!,
                                      displayName!,
                                      isFullyVerified);
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
