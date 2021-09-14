import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qr_scanner_border_painter.dart';

import 'package:lantern/messaging/messaging.dart';

class AddViaQR extends StatefulWidget {
  final Contact me;

  AddViaQR({Key? key, required this.me}) : super(key: key);

  @override
  _AddViaQRState createState() => _AddViaQRState();
}

class _AddViaQRState extends State<AddViaQR> with TickerProviderStateMixin {
  late MessagingModel model;
  String? provisionalContactId;
  int timeoutMillis = 0;
  late AnimationController countdownController;

  bool usingId = false;
  final _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  bool scanning = false;
  StreamSubscription<Barcode>? subscription;
  bool proceedWithoutProvisionals = false;
  ValueNotifier<Contact?>? contactNotifier;
  void Function()? listener;

  final closeOnce = once();

  final _formKey = GlobalKey<FormState>(debugLabel: 'contactIdInput');
  late final contactIdController = CustomTextEditingController(
      formKey: _formKey,
      validator: (value) => value == null ||
              value.isEmpty ||
              value == widget.me.contactId.id ||
              value.length != widget.me.contactId.id.length
          ? 'contact_id_error_description'.i18n
          : null);

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
    }
  }

  final addProvisionalContactOnce = once<Future<void>>();

  Future<void> addProvisionalContact(
      MessagingModel model, String contactId) async {
    if (provisionalContactId != null) {
      // we've already added a provisional contact
      return;
    }
    var result = await model.addProvisionalContact(contactId);

    contactNotifier = model.contactNotifier(contactId);
    listener = () async {
      var updatedContact = contactNotifier!.value;
      if (updatedContact != null &&
          updatedContact.mostRecentHelloTs >
              result['mostRecentHelloTsMillis']) {
        countdownController.stop(canceled: true);
        // go back to New Message with the updatedContact info
        closeOnce(() => Navigator.pop(context, updatedContact));
      }
    };
    contactNotifier!.addListener(listener!);
    // immediately invoke listener in case the contactNotifier already has
    // an up-to-date contact.
    listener!();

    final int expiresAt = result['expiresAtMillis'];
    (expiresAt > 0)
        ? _onCountdownTriggered(expiresAt, contactId)
        : _onNoCountdown();
  }

  void _onNoCountdown() {
    // TODO: we need to show something to the user to indicate that we're
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

    unawaited(countdownController.forward().then((value) {
      // we ran out of time before completing handshake, go back without adding
      closeOnce(() => Navigator.pop(context, null));
      countdownController.stop(canceled: true);
    }));
  }

  void _onQRViewCreated(QRViewController controller, MessagingModel model) {
    qrController = controller;
    qrController?.pauseCamera();
    setState(() {
      scanning = true;
    });
    subscription = qrController?.scannedDataStream.listen((scanData) async {
      try {
        await addProvisionalContactOnce(() {
          contactIdController.text = scanData.code;
          return addProvisionalContact(model, scanData.code);
        });
      } catch (e, s) {
        setState(() {
          scanning = false;
        });
        showErrorDialog(context, e: e, s: s, des: 'qr_error_description'.i18n);
      } finally {
        await qrController?.pauseCamera();
      }
    });
  }

  void _onContactIdAdd() async {
    // checking if the input field is not empty
    if (_formKey.currentState!.validate()) {
      await addProvisionalContactOnce(() {
        return addProvisionalContact(
            model, contactIdController.text.replaceAll('\-', ''));
      });
    }
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
    contactIdController.dispose();
    countdownController.dispose();
    if (listener != null) {
      contactNotifier?.removeListener(listener!);
    }
    if (provisionalContactId != null) {
      // when exiting this screen, immediately delete any provisional contact
      model.deleteProvisionalContact(provisionalContactId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    model = context.watch<MessagingModel>();
    return usingId ? renderIdForm(context) : renderQRScanner(context);
  }

  Widget renderQRScanner(BuildContext context) {
    return fullScreenDialogLayout(
      context: context,
      iconColor: white,
      // icon color
      topColor: grey5,
      title: Center(
        child: Text('qr_scanner'.i18n, style: tsFullScreenDialogTitle),
      ),
      onCloseCallback: () => closeOnce(() => Navigator.pop(context, null)),
      child: Container(
        color: grey5,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ((provisionalContactId != null && scanning))
                        ? PulseAnimation(
                            Text(
                              'qr_info_waiting_qr'.i18n,
                              style: tsInfoDialogText(white),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Row(
                            children: [
                              Text(
                                'qr_info_scan'.i18n,
                                style: tsInfoDialogSubtitle(white),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 4.0),
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
                  ],
                ),
              ),
              // QR scanner for other contact
              Flexible(
                flex: 2,
                child: Container(
                  margin: const EdgeInsetsDirectional.only(top: 16, bottom: 16),
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
                        if ((provisionalContactId != null && scanning) ||
                            proceedWithoutProvisionals)
                          _renderWaitingUI(
                              proceedWithoutProvisionals:
                                  proceedWithoutProvisionals,
                              countdownController: countdownController,
                              timeoutMillis: timeoutMillis,
                              fontColor: white,
                              infoText: ''),
                      ],
                    ),
                  ),
                ),
              ),
              // my own QR code
              Text(
                'qr_for_your_contact'.i18n,
                style: tsInfoDialogText(white),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  margin: const EdgeInsetsDirectional.only(top: 16, bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: QrImage(
                      data: widget.me.contactId.id,
                      padding: const EdgeInsets.all(8),
                      backgroundColor: white,
                      foregroundColor: black,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
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
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0, 15.0, 0, 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0, 16.0, 0),
                          child: Text(
                            'qr_add_via_id'.i18n,
                            style: tsInfoDialogText(white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0, 16.0, 0),
                          child: Icon(Icons.keyboard_arrow_right, color: white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Widget renderIdForm(BuildContext context) {
    return fullScreenDialogLayout(
      topColor: Colors.white,
      iconColor: Colors.black,
      context: context,
      title: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('qr_trouble_scanning'.i18n,
              style: const TextStyle(fontSize: 20)),
        ],
      ),
      backButton: const Icon(Icons.arrow_back),
      onBackCallback: () {
        setState(() {
          usingId = false;
        });
      },
      onCloseCallback: () => Navigator.pop(context, null),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (provisionalContactId == null &&
                            !proceedWithoutProvisionals)
                          Padding(
                            padding: const EdgeInsetsDirectional.all(20.0),
                            child: Wrap(
                              children: [
                                CustomTextField(
                                    controller: contactIdController,
                                    label: 'contact_id_messenger_id'.i18n,
                                    helperText:
                                        'contact_id_enter_manually'.i18n,
                                    keyboardType: TextInputType.text,
                                    minLines: 2,
                                    maxLines: null,
                                    suffixIcon:
                                        const Icon(Icons.keyboard_arrow_right)),
                              ],
                            ),
                          ),
                        if (provisionalContactId != null ||
                            proceedWithoutProvisionals)
                          Expanded(
                            flex: 0,
                            child: Container(
                              margin: const EdgeInsetsDirectional.all(20.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: grey3,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                              ),
                              child: _renderWaitingUI(
                                proceedWithoutProvisionals:
                                    proceedWithoutProvisionals,
                                countdownController: countdownController,
                                timeoutMillis: timeoutMillis,
                                fontColor: black,
                                infoText: 'qr_info_waiting_id'.i18n,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsetsDirectional.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 10),
                                    child: Text(
                                      'contact_id_your_id'.i18n.toUpperCase(),
                                      style:
                                          TextStyle(color: black, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(thickness: 1, color: grey3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        showSnackbar(
                                          context: context,
                                          content: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                'copied'.i18n,
                                                style: tsInfoDialogText(white),
                                                textAlign: TextAlign.left,
                                              )),
                                            ],
                                          ),
                                        );
                                        Clipboard.setData(ClipboardData(
                                            text: widget.me.contactId.id));
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 10.0, end: 10),
                                        child: Text(
                                            humanizeContactId(
                                                widget.me.contactId.id),
                                            overflow: TextOverflow.visible,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                height: 26 / 16)),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: widget.me.contactId.id));
                                        showSnackbar(
                                          context: context,
                                          content: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                'copied'.i18n,
                                                style: tsInfoDialogText(white),
                                                textAlign: TextAlign.left,
                                              )),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: CustomAssetImage(
                                        path: ImagePaths.content_copy,
                                        size: 20,
                                        color: black,
                                      ))
                                ],
                              ),
                              Divider(thickness: 1, color: grey3),
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
              if (provisionalContactId == null && !proceedWithoutProvisionals)
                Container(
                  margin: const EdgeInsetsDirectional.only(bottom: 32),
                  child: Button(
                    width: 200,
                    text: 'Submit'.i18n,
                    onPressed: () {
                      _onContactIdAdd();
                      FocusScope.of(context).unfocus();
                    },
                    disabled: provisionalContactId != null ||
                        proceedWithoutProvisionals,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _renderWaitingUI extends StatelessWidget {
  const _renderWaitingUI(
      {Key? key,
      required this.proceedWithoutProvisionals,
      this.countdownController,
      this.timeoutMillis,
      required this.fontColor,
      required this.infoText})
      : super(key: key);

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
          child: CustomAssetImage(path: ImagePaths.check_green, size: 40),
        ),
        if (!proceedWithoutProvisionals)
          Padding(
            padding: const EdgeInsetsDirectional.only(
                start: 8.0, end: 8.0, top: 8.0),
            child: Text(
              'scan_complete'.i18n,
              style: tsInfoDialogSubtitle(fontColor),
            ),
          ),
        if (!proceedWithoutProvisionals)
          Padding(
            padding: const EdgeInsetsDirectional.all(8.0),
            child: Countdown.build(
              controller: countdownController!,
              textStyle: tsCountdownTimer(fontColor),
              durationSeconds: timeoutMillis! ~/ 1000,
            ),
          ),
        if (infoText.isNotEmpty)
          PulseAnimation(
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 20.0, top: 16.0, bottom: 16.0, end: 20.0),
                child: Text(
                  infoText,
                  style: tsInfoDialogText(fontColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
