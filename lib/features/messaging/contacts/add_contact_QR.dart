import 'package:lantern/features/messaging/messaging.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'qr_scanner_border_painter.dart';

class AddViaQR extends StatefulWidget {
  final Contact me;
  final bool isVerificationMode;

  AddViaQR({Key? key, required this.me, this.isVerificationMode = true})
      : super(key: key);

  @override
  _AddViaQRState createState() => _AddViaQRState();
}

class _AddViaQRState extends State<AddViaQR> with TickerProviderStateMixin {
  String? provisionalContactId;
  int timeoutMillis = 0;
  late AnimationController countdownController;

  // bool usingId = false;
  final _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool scanning = false;
  StreamSubscription<Barcode>? subscription;
  bool proceedWithoutProvisionals = false;
  ValueNotifier<Contact?>? contactNotifier;
  void Function()? listener;

  // Helper functions
  final closeOnce = once();
  final addOnce = once<Future<void>>();

  // THIS IS ONLY FOR DEBUGGING PURPOSES
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      // qrController?.pauseCamera();
      setState(() {
        scanning = false;
      });
    }
  }

  Future<void> _addProvisionalContact(
    MessagingModel model,
    String unsafeId,
    String source,
  ) async {
    if (provisionalContactId != null) {
      // we've already added a provisional contact
      return;
    }

    /*
    * Add provisional contact - regardless of whether we are in verifying or face-to-face adding mode, adding an unverified provisional contact
    */
    var result = await model.addProvisionalContact(unsafeId, source);

    // TODO: repeated pattern
    // listen to the contact path for changes
    // will return a Contact if there are any, otherwise null
    contactNotifier = model.contactNotifier(unsafeId);

    listener = () async {
      var updatedContact = contactNotifier!.value;
      if (updatedContact != null &&
          updatedContact.mostRecentHelloTs >
              result['mostRecentHelloTsMillis']) {
        countdownController.stop(canceled: true);
        closeOnce(() => Navigator.pop(context, updatedContact));
      }
    };
    contactNotifier!.addListener(listener!);
    // immediately invoke listener in case the contactNotifier already has
    // an up-to-date contact.
    listener!();

    final int expiresAt = result['expiresAtMillis'];
    (expiresAt > 0)
        ? _onCountdownTriggered(expiresAt, unsafeId)
        : _onNoCountdown();
  }

  void _onNoCountdown() {
    // we need to show something to the user to indicate that we're
    // waiting on the other person to scan the QR code, but in this case
    // there is no time limit.
    setState(() {
      proceedWithoutProvisionals = true;
    });
  }

  void _onCountdownTriggered(int expiresAt, String contactId) {
    final timeout = expiresAt - DateTime.now().millisecondsSinceEpoch;
    setState(() {
      provisionalContactId = contactId;
      timeoutMillis = timeout;
      countdownController.duration = Duration(milliseconds: timeoutMillis);
    });

    unawaited(
      countdownController.forward().then((value) {
        // we ran out of time before completing handshake, go back without adding
        closeOnce(() => Navigator.pop(context, null));
        countdownController.stop(canceled: true);
      }),
    );
  }

  void _onQRViewCreated(QRViewController controller, MessagingModel model) {
    qrController = controller;
    qrController?.pauseCamera();
    setState(() {
      scanning = true;
    });
    subscription = qrController?.scannedDataStream.listen((scanData) async {
      try {
        await addOnce(() {
          return _addProvisionalContact(model, scanData.code!, 'qr');
        });
      } catch (e, s) {
        setState(() {
          scanning = false;
        });
        CDialog.showError(
          context,
          error: e,
          stackTrace: s,
          description: 'qr_error_description'.i18n,
        );
      } finally {
        await qrController?.pauseCamera();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    countdownController =
        AnimationController(vsync: this, duration: const Duration(hours: 24));
  }

  @override
  void dispose() {
    subscription?.cancel();
    qrController?.dispose();
    countdownController.dispose();
    if (listener != null) {
      contactNotifier?.removeListener(listener!);
    }
    if (provisionalContactId != null) {
      // when exiting this screen, immediately delete any provisional contact
      messagingModel.deleteProvisionalContact(provisionalContactId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Container(
            color: grey5,
            height: 100,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.only(top: 25),
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: mirrorLTR(
                      context: context,
                      child: CAssetImage(
                        path: ImagePaths.arrow_back,
                        color: white,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                ),
                Container(
                  padding: const EdgeInsetsDirectional.only(top: 25),
                  alignment: Alignment.center,
                  child: Center(
                    child: CText(
                      widget.isVerificationMode
                          ? 'contact_verification'.i18n
                          : 'banner_source_qr'.i18n,
                      style: tsHeading3.copiedWith(color: white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: grey5,
              padding: const EdgeInsetsDirectional.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(4),
                      child: (provisionalContactId != null && scanning)
                          ? PulseAnimation(
                              CText(
                                'qr_info_waiting_qr'.i18n,
                                style: tsBody1Color(white),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: CText(
                                    widget.isVerificationMode
                                        ? 'qr_info_verification_scan'.i18n
                                        : 'qr_info_f2f_scan'.i18n,
                                    style: tsBody1Color(white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 4.0,
                                  ),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => CDialog(
                                      title: widget.isVerificationMode
                                          ? 'qr_info_verification_title'.i18n
                                          : 'qr_info_f2f_title'.i18n,
                                      description: widget.isVerificationMode
                                          ? 'qr_info_verification_des'.i18n
                                          : 'qr_info_f2f_des'.i18n,
                                      iconPath: ImagePaths.qr_code,
                                    ).show(context),
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
                  ),
                  /*
              * QR SCANNER
              */
                  Flexible(
                    child: Container(
                      padding: const EdgeInsetsDirectional.only(
                        top: 20.0,
                        start: 70,
                        end: 70,
                        bottom: 20.0,
                      ),
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
                                          _onQRViewCreated(
                                        controller,
                                        messagingModel,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if ((provisionalContactId != null && scanning) ||
                                proceedWithoutProvisionals)
                              _renderWaitingUI(
                                proceedWithoutProvisionals:
                                    proceedWithoutProvisionals,
                                countdownController: countdownController,
                                timeoutMillis: timeoutMillis,
                                fontColor: white,
                                infoText: '',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  /*
              * YOUR QR CODE
              */
                  CText(
                    'qr_for_your_contact'.i18n,
                    style: tsBody1Color(white),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsetsDirectional.only(
                        top: 20.0,
                        start: 70,
                        end: 70,
                        bottom: 20.0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: QrImageView(
                          data: widget.me.contactId.id,
                          padding: const EdgeInsets.all(16),
                          backgroundColor: white,
                          eyeStyle: QrEyeStyle(color: black),
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _renderWaitingUI extends StatelessWidget {
  const _renderWaitingUI({
    Key? key,
    required this.proceedWithoutProvisionals,
    this.countdownController,
    this.timeoutMillis,
    required this.fontColor,
    required this.infoText,
  }) : super(key: key);

  final bool proceedWithoutProvisionals;
  final AnimationController? countdownController;
  final int? timeoutMillis;
  final Color fontColor;
  final String infoText;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.only(top: 16.0),
          child: CAssetImage(path: ImagePaths.check_green_large, size: 40),
        ),
        if (!proceedWithoutProvisionals)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 8.0,
              end: 8.0,
              top: 8.0,
            ),
            child: CText(
              'scan_complete'.i18n,
              style: tsBody1Color(fontColor),
            ),
          ),
        if (!proceedWithoutProvisionals)
          Padding(
            padding: const EdgeInsetsDirectional.all(8.0),
            child: Countdown.build(
              controller: countdownController!,
              textStyle: tsDisplay(fontColor),
              durationSeconds: timeoutMillis! ~/ 1000,
            ),
          ),
        if (infoText.isNotEmpty)
          PulseAnimation(
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 20.0,
                  top: 16.0,
                  bottom: 16.0,
                  end: 20.0,
                ),
                child: CText(
                  infoText,
                  style: tsBody1Color(fontColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
