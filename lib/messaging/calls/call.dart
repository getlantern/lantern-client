import 'package:lantern/messaging/messaging.dart';

import 'signaling.dart';

class Call extends StatefulWidget {
  final Contact contact;
  final MessagingModel model;
  final Session? initialSession;

  Call({required this.contact, required this.model, this.initialSession})
      : super();

  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call> with WidgetsBindingObserver {
  late Future<Session> session;
  late Signaling signaling;
  var closed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    signaling = widget.model.signaling;
    signaling.addListener(onSignalingStateChange);
    if (widget.initialSession != null) {
      session = Future.value(widget.initialSession!);
    } else {
      session = signaling.call(
        peerId: widget.contact.contactId.id,
        media: 'audio',
        onError: () {
          showConfirmationDialog(
              context: context,
              title: 'unable_to_complete_call'.i18n,
              explanation: 'please_try_again'.i18n,
              agreeText: 'close'.i18n,
              agreeAction: () async {
                signaling.bye(await session);
              });
        },
      );
    }
  }

  @override
  void dispose() async {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    signaling.removeListener(onSignalingStateChange);
    signaling.bye(await session);
  }

  void onSignalingStateChange() {
    if (signaling.value.callState == CallState.Bye) {
      if (!closed) {
        Navigator.pop(context);
        closed = true;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        notifications.showInCallNotification(widget.contact);
        break;
      case AppLifecycleState.resumed:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: signaling,
        builder: (BuildContext context, SignalingState signalingState,
            Widget? child) {
          return SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                color: black,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(padding: EdgeInsetsDirectional.all(80)),
                        CustomAvatar(
                            id: widget.contact.contactId.id,
                            displayName: widget.contact.displayName,
                            customColor: grey5,
                            radius: 80),
                        Container(
                          child: CText(
                            widget.contact.displayName.isNotEmpty
                                ? widget.contact.displayName
                                : widget.contact.contactId.id,
                            style: tsHeading1.copiedWith(color: white),
                          ),
                        ),
                        Container(
                          child: CText(
                            signaling.value.callState == CallState.Connected
                                ? 'connected'.i18n
                                : 'Connecting'.i18n,
                            style: tsBody1.copiedWith(color: white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.all(20.0),
                          child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: [
                              RoundButton(
                                diameter: 70,
                                padding: 15,
                                icon: CAssetImage(
                                    path: ImagePaths.speaker,
                                    color: signalingState.speakerphoneOn
                                        ? grey5
                                        : white),
                                backgroundColor: signalingState.speakerphoneOn
                                    ? white
                                    : grey5,
                                onPressed: () {
                                  signaling.toggleSpeakerphone();
                                },
                              ),
                              Transform.translate(
                                offset: const Offset(0.0, 30.0),
                                child: CText(
                                    signalingState.speakerphoneOn
                                        ? 'speaker_on'.i18n
                                        : 'speaker'.i18n,
                                    style: tsBody1.copiedWith(color: white)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.all(20.0),
                          child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: [
                              RoundButton(
                                diameter: 70,
                                padding: 15,
                                icon: CAssetImage(
                                    path: ImagePaths.mute,
                                    color:
                                        signalingState.muted ? grey5 : white),
                                backgroundColor:
                                    signalingState.muted ? white : grey5,
                                onPressed: () {
                                  signaling.toggleMute();
                                },
                              ),
                              Transform.translate(
                                offset: const Offset(0.0, 30.0),
                                child: CText(
                                    signalingState.muted
                                        ? 'muted'.i18n
                                        : 'mute'.i18n,
                                    style: tsBody1.copiedWith(color: white)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.all(20.0),
                          child: Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: [
                              RoundButton(
                                diameter: 70,
                                padding: 15,
                                icon:
                                    const CAssetImage(path: ImagePaths.hangup),
                                backgroundColor: indicatorRed,
                                onPressed: () async {
                                  signaling.bye(await session);
                                },
                              ),
                              Transform.translate(
                                offset: const Offset(0.0, 30.0),
                                child: CText('end_call'.i18n,
                                    style: tsBody1.copiedWith(color: white)),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  const Padding(padding: EdgeInsetsDirectional.all(20)),
                ],
              ),
            ),
          );
        });
  }
}
