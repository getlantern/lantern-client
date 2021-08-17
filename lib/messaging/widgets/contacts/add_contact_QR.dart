import 'dart:async';
import 'dart:io';

import 'package:lantern/core/router/router_extensions.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddViaQR extends StatefulWidget {
  @override
  _AddViaQRState createState() => _AddViaQRState();
}

class _AddViaQRState extends State<AddViaQR> {
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
        if (await model.addProvisionalContact(contactId)) {
          // we successfully added a provisional contact, listen for a Contact
          var contactNotifier = model.contactNotifier(contactId);
          late void Function() listener;
          listener = () async {
            var updatedContact = contactNotifier.value;
            if (updatedContact != null) {
              contactNotifier.removeListener(listener);
              Navigator.of(context).pop(); // close the full screen dialog
              await context.openConversation(updatedContact);
            }
          };
          contactNotifier.addListener(listener);
          // immediately invoke listener in case the contactNotifier already has
          // a contact.
          listener();
        }
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
    return buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    return model.me((BuildContext context, Contact me, Widget? child) {
      return fullScreenDialogLayout(Colors.black, Colors.white, context, [
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                      "Scan your friend's QR code and ask them to scan yours."
                          .i18n,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                      )),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => showInfoDialog(context,
                      title: 'Scan QR Code'.i18n,
                      des:
                          "To start a message with your friend, scan each other's QR code.  This process will verify the security and end-to-end encryption of your conversation."
                              .i18n,
                      icon: ImagePaths.qr_code,
                      buttonText: 'GOT IT'.i18n),
                  child: const Icon(
                    Icons.info,
                    size: 14,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                child: QrImage(
                  data: me.contactId.id,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: QRView(
                    key: _qrKey,
                    onQRViewCreated: (controller) =>
                        _onQRViewCreated(controller, model),
                  ),
                ),
                if (scannedContactId != null)
                  const CustomAssetImage(
                      path: ImagePaths.check_grey, size: 200),
              ],
            ),
          ),
        ),
      ]);
    });
  }
}
