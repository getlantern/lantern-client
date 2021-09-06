import 'dart:async';
import 'dart:io';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/contacts/add_contactId.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/scale_animation_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddViaQR extends StatefulWidget {
  @override
  _AddViaQRState createState() => _AddViaQRState();
}

class _AddViaQRState extends State<AddViaQR> {
  bool usingId = false;
  final _qrKey = GlobalKey(debugLabel: 'QR');
  late MessagingModel model;
  QRViewController? qrController;
  bool scanning = false;
  String? scannedContactId;
  StreamSubscription<Barcode>? subscription;

  // THIS IS ONLY FOR DEBUGGING PURPOSES
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
      scanning = true;
    });
    subscription = qrController?.scannedDataStream.listen((scanData) async {
      try {
        if (scannedContactId != null) {
          // we've already scanned the contact, don't bother processing again
          return;
        }
        final contactId = scanData.code;
        setState(() {
          scannedContactId = contactId;
        });
        var mostRecentHelloTs =
            await model.addProvisionalContact(scannedContactId!);
        var contactNotifier = model.contactNotifier(scannedContactId!);
        late void Function() listener;
        listener = () async {
          var updatedContact = contactNotifier.value;
          if (updatedContact != null &&
              updatedContact.mostRecentHelloTs > mostRecentHelloTs) {
            contactNotifier.removeListener(listener);
            // go back to New Message with the updatedContact info
            Navigator.pop(context, updatedContact);
          }
        };
        contactNotifier.addListener(listener);
        // immediately invoke listener in case the contactNotifier already has
        // an up-to-date contact.
        listener();
      } catch (e) {
        setState(() {
          scanning = false;
        });
        showInfoDialog(context,
            title: 'Error'.i18n,
            des: 'Something went wrong while scanning the QR code'.i18n,
            icon: ImagePaths.alert_icon,
            buttonText: 'OK'.i18n);
      } finally {
        await qrController?.pauseCamera();
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    qrController?.dispose();
    if (scannedContactId != null) {
      // when exiting this screen, immediately delete any provisional contact
      model.deleteProvisionalContact(scannedContactId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();
    return model.me((BuildContext context, Contact me, Widget? child) {
      return usingId ? AddViaContactIdBody(me) : renderQRscanner(context, me);
    });
  }

  Widget renderQRscanner(BuildContext context, Contact me) {
    var middleColor = grey3;
    var bottomColor = Colors.white;
    return fullScreenDialogLayout(
        context: context,
        iconColor: Colors.white, // icon color
        topColor: Colors.black,
        title: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('QR Scanner'.i18n.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                )),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => showInfoDialog(context,
                    title: 'Scan QR Code'.i18n,
                    des:
                        "To start a message with your friend, scan each other's QR code.  This process will verify the security and end-to-end encryption of your conversation."
                            .i18n,
                    icon: ImagePaths.qr_code,
                    buttonText: 'Got it'.i18n.toUpperCase()),
                child: const Icon(
                  Icons.info,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // QR scanner for other contact
              Expanded(
                flex: 3,
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Flexible(
                      child: Container(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            QRView(
                              key: _qrKey,
                              onQRViewCreated: (controller) =>
                                  _onQRViewCreated(controller, model),
                              overlay: QrScannerOverlayShape(
                                borderColor: Colors.greenAccent,
                                borderRadius: 8,
                                borderLength: 15,
                                borderWidth: 5,
                                cutOutSize: 300,
                              ),
                            ),
                            if (scannedContactId != null && scanning)
                              ScaleAnimationWidget(
                                const CustomAssetImage(
                                    path: ImagePaths.check_green, size: 80),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // my own QR code
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      color: middleColor,
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      alignment: Alignment.center,
                      child: Text('For your Contact'.i18n,
                          style: const TextStyle(
                            color: Colors.black,
                          )),
                    ),
                    Flexible(
                      child: Container(
                        color: middleColor,
                        padding: const EdgeInsets.only(bottom: 20.0),
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: grey5,
                              width: 3,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          child: QrImage(
                            data: me.contactId.id,
                            foregroundColor: Colors.black54,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Trouble scanning
              Flexible(
                flex: 0,
                child: Container(
                  color: bottomColor,
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            usingId = true;
                          });
                          qrController?.pauseCamera();
                        },
                        child: Text('Trouble scanning?'.i18n,
                            style: const TextStyle(
                              color: Colors.black,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ]));
  }
}
