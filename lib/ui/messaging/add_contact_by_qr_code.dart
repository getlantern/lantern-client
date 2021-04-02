import 'dart:io';

import 'package:lantern/package_store.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AddContactByQrCode extends StatefulWidget {
  @override
  _AddContactByQrCodeState createState() => _AddContactByQrCodeState();
}

class _AddContactByQrCodeState extends State<AddContactByQrCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  Barcode result;
  QRViewController controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.pauseCamera();
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(result?.code ?? ""),
        ),
      ],
    );
  }
}
