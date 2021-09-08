import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/contacts/add_contactId.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/clipped_rect_border.dart';
import 'package:lantern/ui/widgets/pulse_animation.dart';
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
            title: 'error'.i18n,
            des: 'qr_error_description'.i18n,
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
    return fullScreenDialogLayout(
        context: context,
        iconColor: white, // icon color
        topColor: grey5,
        title: Center(
          child: Text('qr_scanner'.i18n.toUpperCase(),
              style: tsFullScreenDialogTitle),
        ),
        child: Container(
          color: grey5,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16.0, 0, 0),
                  alignment: Alignment.center,
                  child: (scannedContactId != null && scanning)
                      ? PulseAnimation(
                          Text('qr_info_waiting'.i18n,
                              style: TextStyle(
                                color: white,
                              )),
                        )
                      : Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('qr_info_scan'.i18n,
                                style: TextStyle(
                                  color: white,
                                )),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 4.0),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () => showInfoDialog(context,
                                    title: 'qr_info_title'.i18n,
                                    des: 'qr_info_description'.i18n,
                                    icon: ImagePaths.qr_code,
                                    buttonText: 'info_dialog_confirm'
                                        .i18n
                                        .toUpperCase()),
                                child: const Icon(
                                  Icons.info,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                ),
                // QR scanner for other contact
                Expanded(
                  flex: 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: ClippedRectBorderPainter(),
                        child: Container(
                          padding: const EdgeInsetsDirectional.all(10.0),
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: QRView(
                                key: _qrKey,
                                onQRViewCreated: (controller) =>
                                    _onQRViewCreated(controller, model),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (scannedContactId != null && scanning)
                        const CustomAssetImage(
                            path: ImagePaths.check_green, size: 40),
                    ],
                  ),
                ),
                // my own QR code
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0, 16.0, 0, 16.0),
                        alignment: Alignment.center,
                        child: Text('qr_for_your_contact'.i18n,
                            style: TextStyle(
                              color: white,
                            )),
                      ),
                      Flexible(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: QrImage(
                              data: me.contactId.id,
                              backgroundColor: white,
                              foregroundColor: black,
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
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        usingId = true;
                      });
                      qrController?.pauseCamera();
                    },
                    child: Container(
                      color: black,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0, 15.0, 0, 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0, 16.0, 0),
                            child: Text('qr_trouble_scanning'.i18n,
                                style: TextStyle(
                                    color: white, fontWeight: FontWeight.w400)),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0, 16.0, 0),
                            child:
                                Icon(Icons.keyboard_arrow_right, color: white),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
        ));
  }
}
