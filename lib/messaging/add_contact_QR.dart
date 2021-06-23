import 'dart:async';
import 'dart:io';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
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
  Contact? scannedContact;

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
        listener = () {
          var updatedContact = contactNotifier.value;
          if (updatedContact != null &&
              updatedContact.firstReceivedMessageTs > 0) {
            contactNotifier.removeListener(listener);
            Navigator.pushNamed(context, '/conversation',
                arguments: updatedContact);
          }
        };
        contactNotifier.addListener(listener);
        await model.addOrUpdateDirectContact(
            contact.contactId.id, contact.displayName);
      } catch (e) {
        setState(() {
          scanning = false;
        });
        showInfoDialog(
          context,
          title: 'Error'.i18n,
          des:
              'Something went wrong while scanning the QR code', // TODO: Add i18n
        );
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
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                    top: 10, start: 10, end: 10),
                child: Text(
                  "Scan your friend's QR code and ask them to do the same."
                      .i18n,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: AspectRatio(
                aspectRatio: 1,
                child: QrImage(
                  data: '${me.contactId.id}|${me.displayName}',
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              ),
            ),
            Flexible(
              flex: 4,
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
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Icon(
                        Icons.check_circle_outline_outlined,
                        size: 50.w,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    var model = context.watch<MessagingModel>();

    return BaseScreen(title: 'QR Code'.i18n, body: buildBody(context, model));
  }
}
