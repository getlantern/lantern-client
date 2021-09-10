import 'dart:async';
import 'dart:io';

import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/messaging/widgets/contacts/add_contactId.dart';
import 'package:lantern/messaging/widgets/message_utils.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';
import 'package:lantern/ui/widgets/countdown_min_sec.dart';
import 'package:lantern/ui/widgets/pulse_animation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'add_contact.dart';
import 'qr_scanner_border_painter.dart';

class AddViaQR extends StatefulWidget {
  @override
  _AddViaQRState createState() => _AddViaQRState();
}

class _AddViaQRState extends AddContactState<AddViaQR> {
  bool usingId = false;
  final _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool scanning = false;
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
        if (provisionalContactId?.isNotEmpty == true) {
          // we've already scanned the contact, don't bother processing again
          return;
        }
        await addProvisionalContact(model, scanData.code);
      } catch (e) {
        print(e);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();
    return model.me((BuildContext context, Contact me, Widget? child) {
      return usingId ? AddViaContactIdBody(me) : renderQRScanner(context, me);
    });
  }

  Widget renderQRScanner(BuildContext context, Contact me) {
    return fullScreenDialogLayout(
        context: context,
        iconColor: white,
        // icon color
        topColor: grey5,
        title: Center(
          child: Text('qr_scanner'.i18n, style: tsFullScreenDialogTitle),
        ),
        child: Container(
          color: grey5,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: (provisionalContactId != null && scanning)
                      ? PulseAnimation(
                          Text(
                            'qr_info_waiting_ID'.i18n,
                            style: tsInfoTextWhite,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'qr_info_scan'.i18n,
                              style: tsInfoTextWhite,
                            ),
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
                                child: Icon(
                                  Icons.info,
                                  size: 14,
                                  color: white,
                                ),
                              ),
                            )
                          ],
                        ),
                ),
                // QR scanner for other contact
                Flexible(
                  flex: 2,
                  child: Container(
                    margin:
                        const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            painter: QRScannerBorderPainter(),
                            child: Container(
                              padding: const EdgeInsetsDirectional.all(6.0),
                              child: Opacity(
                                opacity:
                                    (provisionalContactId != null && scanning)
                                        ? 0.5
                                        : 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: QRView(
                                    key: _qrKey,
                                    onQRViewCreated: (controller) =>
                                        _onQRViewCreated(controller, model),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (provisionalContactId != null && scanning)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CustomAssetImage(
                                    path: ImagePaths.check_green, size: 40),
                                Countdown(
                                  StepTween(
                                    begin: timeoutMillis,
                                    end: 0,
                                  ).animate(countdownController),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // my own QR code
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        'qr_for_your_contact'.i18n,
                        style: tsInfoTextWhite,
                      ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsetsDirectional.only(
                              top: 16, bottom: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: QrImage(
                              data: me.contactId.id,
                              padding: const EdgeInsets.all(8),
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
                Container(
                  // the margin between the QR code and this section is 27,
                  // which we split into 16 margin on the QR and 11 margin here
                  // to make sure that the QR code ends up exactly the same size
                  // as the QR scanner. If we put the full 27 margin on the QR
                  // code, it would render a little smaller than the scanner.
                  margin: const EdgeInsetsDirectional.only(top: 27 - 16),
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
                            child: Text(
                              'qr_trouble_scanning'.i18n,
                              style: tsInfoButton,
                            ),
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
