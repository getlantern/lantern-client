import 'dart:async';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:lantern/core/router/router.gr.dart';
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

  QRViewController? qrController;

  bool scanning = false;
  Contact? scannedContact;

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
    late StreamSubscription<Barcode>? subscription;
    subscription = qrController?.scannedDataStream.listen((scanData) async {
      try {
        if (scannedContact != null) {
          // we've already scanned the contact, don't bother processing again
          return;
        }
        var parts = scanData.code.split('\|');
        var contact = Contact.create();
        contact.contactId = ContactId.create();
        contact.contactId.type = ContactType.DIRECT;
        contact.contactId.id = parts[0];
        contact.displayName = parts[1];
        setState(() {
          scannedContact = contact;
        });
        var contactNotifier = model.contactNotifier(contact);
        late void Function() listener;
        listener = () async {
          var updatedContact = contactNotifier.value;
          if (updatedContact != null &&
              updatedContact.firstReceivedMessageTs > 0) {
            contactNotifier.removeListener(listener);
            Navigator.of(context).pop(); // close the full screen dialog
            await context.router.push(Conversation(contact: updatedContact));
          }
        };
        contactNotifier.addListener(listener);
        await model.addOrUpdateDirectContact(
            contact.contactId.id, contact.displayName);
      } catch (e) {
        setState(() {
          scanning = false;
        });
        showInfoDialog(context,
            title: 'Error'.i18n,
            des:
                'Something went wrong while scanning the QR code', // TODO: Add i18n
            icon: ImagePaths.alert_icon,
            buttonText: 'OK'.i18n);
      } finally {
        await subscription?.cancel();
        await qrController?.pauseCamera();
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

    return buildBody(context, model);
  }

  Widget buildBody(BuildContext context, MessagingModel model) {
    if (scannedContact == null) {
      return doBuildBody(context, model, null);
    }

    return model.singleContact(context, scannedContact!,
        (context, contact, child) => doBuildBody(context, model, contact));
  }

  Widget doBuildBody(
      BuildContext context, MessagingModel model, Contact? contact) {
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
                      "Scan your friend's QR code and ask them to scan yours." // TODO: Add i18n
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
                  data: '${me.contactId.id}|${me.displayName}',
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
                if (contact != null)
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
