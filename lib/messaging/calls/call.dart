import 'package:lantern/messaging/messaging.dart';

import 'signaling.dart';

class Call extends StatefulWidget {
  final Contact contact;
  final Session? initialSession;

  Call({required this.contact, this.initialSession}) : super();

  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call> with WidgetsBindingObserver {
  Session? session;
  late Signaling signaling;
  var closed = false;
  var isPanelShowing = false;
  var isVerified = false;
  var fragmentStatusMap = {};
  var incoming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    disableBackButton();
    signaling = messagingModel.signaling;

    // initialize fragment - status map after breaking down numericFingerprint in groups of 5
    humanizeVerificationNum(widget.contact.numericFingerprint).asMap().forEach(
          (key, value) => fragmentStatusMap[key] = {
            'fragment': value,
            'isConfirmed': false
          },
        );

    if (widget.initialSession != null) {
      incoming = true;
      session = widget.initialSession!;
      session!.addListener(onSignalingStateChange);
    } else {
      signaling
          .call(
        peerId: widget.contact.contactId.id,
        media: 'audio',
      )
          .then((value) {
        setState(() => session = value);
        session!.addListener(onSignalingStateChange);
      });
    }
  }

  @override
  void dispose() async {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    enableBackButton();
    if (session != null) {
      session!.removeListener(onSignalingStateChange);
      await signaling.bye(session!);
    }
    unawaited(notifications.dismissInCallNotification());
    await Wakelock.disable();
  }

  void onSignalingStateChange() async {
    if (session!.value.callState == CallState.Bye) {
      if (!closed) {
        if (incoming) {
          // For incoming calls, open the conversation corresponding to this
          // the contact with whom we were just on a call.
          await context.router
              .replace(Conversation(contactId: widget.contact.contactId));
        } else {
          // Pop back to wherever we were, whether or not we've verified the contact.
          Navigator.pop(context, isVerified);
        }
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

  String getCallStatus(CallState callState) {
    switch (callState) {
      case CallState.Connected:
        return 'Connected'.i18n;
      case CallState.Bye:
        return 'Disconnecting'.i18n;
      default:
        return 'Calling'.i18n;
    }
  }

  void handleTapping(int key) async {
    var _status = fragmentStatusMap[key]['isConfirmed'];
    markFragments(!_status, key);
    if (fragmentsAreVerified()) {
      await messagingModel
          .markDirectContactVerified(widget.contact.contactId.id);
      setState(() => isVerified = true);
    }
  }

  // returns true if all the fragments have been verified
  bool fragmentsAreVerified() {
    return !fragmentStatusMap.entries
        .any((element) => element.value['isConfirmed'] == false);
  }

  void handleVerifyButtonPress() async {
    if (isVerified) {
      markFragments(false, null); // mark all fragments as unverified
      isVerified = false;
    } else {
      markFragments(true, null); // mark all fragments as verified
      isVerified = true;
      await messagingModel
          .markDirectContactVerified(widget.contact.contactId.id);
    }
  }

  void markFragments(bool value, int? key) {
    // mark one fragment
    if (key != null) {
      setState(() {
        fragmentStatusMap[key]['isConfirmed'] = value;
      });
    } else {
      // mark all fragments
      setState(() {
        fragmentStatusMap.updateAll(
          (key, el) => {'fragment': el['fragment'], 'isConfirmed': value},
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return Container();
    }
    Wakelock.toggle(
      enable: isPanelShowing,
    ); // keep screen awake when panel is showing
    return LayoutBuilder(
      builder: (context, constraints) => ValueListenableBuilder(
        valueListenable: session!,
        builder: (
          BuildContext context,
          SignalingState signalingState,
          Widget? child,
        ) {
          return Container(
            decoration: BoxDecoration(
              color: black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //* Avatar, title and call status
                isPanelShowing
                    ? Container(
                        padding: const EdgeInsetsDirectional.only(
                          start: 16.0,
                          top: 40.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsetsDirectional.all(8.0),
                              child: CustomAvatar(
                                messengerId: widget.contact.contactId.id,
                                displayName: widget.contact.displayName,
                              ),
                            ),
                            renderTitle(constraints)
                          ],
                        ),
                      )
                    : Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsetsDirectional.all(8.0),
                              child: CustomAvatar(
                                messengerId: widget.contact.contactId.id,
                                displayName: widget.contact.displayName,
                                radius: 64,
                                textStyle: tsDisplayBlack,
                              ),
                            ),
                            renderTitle(constraints)
                          ],
                        ),
                      ),
                //* Verification panel
                if (isPanelShowing)
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsetsDirectional.only(top: 8.0),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          decoration: BoxDecoration(
                            color: grey5,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //* Text and icon
                              Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: white,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => isPanelShowing = false,
                                      );
                                      if (!fragmentsAreVerified() ||
                                          !isVerified) {
                                        markFragments(
                                          false,
                                          null,
                                        ); // mark all fragments as unverified since we closed the modal before finishing verification
                                      }
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 24,
                                      end: 24,
                                      top: 32,
                                      bottom: 24,
                                    ),
                                    child: CText(
                                      isVerified
                                          ? 'verification_panel_success'
                                              .i18n
                                              .fill([
                                              widget
                                                  .contact.displayNameOrFallback
                                            ])
                                          : 'verification_panel_pending'
                                              .i18n
                                              .fill([
                                              widget
                                                  .contact.displayNameOrFallback
                                            ]),
                                      style: tsBody1.copiedWith(
                                        color: grey3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              //* Verification number
                              Wrap(
                                children: [
                                  ...fragmentStatusMap.entries.map(
                                    (entry) => CInkWell(
                                      key: ValueKey(entry.key),
                                      onTap: () => handleTapping(entry.key),
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                          start: 5.0,
                                          end: 5.0,
                                          top: 5.0,
                                          bottom: 5.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CText(
                                              (entry.key + 1).toString(),
                                              style: entry.value['isConfirmed']
                                                  ? tsOverlineShort.copiedWith(
                                                      color: grey4,
                                                    )
                                                  : tsOverlineShort.copiedWith(
                                                      color: white,
                                                    ),
                                            ),
                                            CText(
                                              entry.value['fragment']
                                                  .toString(),
                                              style: entry.value['isConfirmed']
                                                  ? tsHeading3.copiedWith(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: grey4,
                                                    )
                                                  : tsHeading3.copiedWith(
                                                      color: white,
                                                    ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  top: 24.0,
                                  bottom: 24.0,
                                ),
                                child: Button(
                                  tertiary: true,
                                  iconPath: isVerified
                                      ? null
                                      : ImagePaths.verified_user,
                                  text: isVerified
                                      ? 'undo_verification'.i18n
                                      : 'mark_as_verified'.i18n,
                                  onPressed: () => handleVerifyButtonPress(),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                //* Verify button
                if (!isPanelShowing && widget.contact.isUnverified())
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        key: const ValueKey('call_verify_button'),
                        padding: const EdgeInsetsDirectional.all(24.0),
                        child: Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            RoundButton(
                              icon: CAssetImage(
                                path: ImagePaths.verified_user,
                                color: white,
                              ),
                              backgroundColor: grey5,
                              onPressed: () =>
                                  setState(() => isPanelShowing = true),
                            ),
                            Transform.translate(
                              offset: const Offset(0.0, 30.0),
                              child: CText(
                                'verification'.i18n,
                                style: tsBody1.copiedWith(color: white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                //* Controls
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 24,
                    start: 24,
                    end: 24,
                  ),
                  child: Table(
                    children: [
                      TableRow(
                        children: [
                          RoundButton(
                            icon: CAssetImage(
                              path: ImagePaths.speaker,
                              color:
                                  signalingState.speakerphoneOn ? grey5 : white,
                            ),
                            backgroundColor:
                                signalingState.speakerphoneOn ? white : grey5,
                            onPressed: () {
                              session!.toggleSpeakerphone();
                            },
                          ),
                          RoundButton(
                            icon: CAssetImage(
                              path: ImagePaths.mute,
                              color: signalingState.muted ? grey5 : white,
                            ),
                            backgroundColor:
                                signalingState.muted ? white : grey5,
                            onPressed: () {
                              session!.toggleMute();
                            },
                          ),
                          RoundButton(
                            icon: const CAssetImage(path: ImagePaths.hangup),
                            backgroundColor: indicatorRed,
                            onPressed: () async {
                              await signaling.bye(session!);
                            },
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          CText(
                            signalingState.speakerphoneOn
                                ? 'speaker_on'.i18n
                                : 'speaker'.i18n,
                            textAlign: TextAlign.center,
                            style: tsBody1.copiedWith(color: white),
                          ),
                          CText(
                            signalingState.muted ? 'muted'.i18n : 'mute'.i18n,
                            textAlign: TextAlign.center,
                            style: tsBody1.copiedWith(color: white),
                          ),
                          CText(
                            'end_call'.i18n,
                            textAlign: TextAlign.center,
                            style: tsBody1.copiedWith(color: white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 40),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // breaks the numericalFingerpint String into groups of 5
  List<dynamic> humanizeVerificationNum(String verificationNum) {
    final verificationNumList =
        widget.contact.numericFingerprint.characters.toList();
    var verificationFragments = [];
    // surely we can do this more efficiently but oh well
    for (var i = 0; i < verificationNumList.length; i += 5) {
      final fragment = verificationNumList
          .sublist(
            i,
            i + 5 > verificationNumList.length
                ? verificationNumList.length
                : i + 5,
          )
          .join();
      verificationFragments.add(fragment);
    }
    return verificationFragments;
  }

  Column renderTitle(BoxConstraints constraints) => Column(
        mainAxisAlignment:
            isPanelShowing ? MainAxisAlignment.start : MainAxisAlignment.center,
        crossAxisAlignment: isPanelShowing
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.7),
            child: CText(
              widget.contact.displayNameOrFallback.isNotEmpty
                  ? widget.contact.displayNameOrFallback
                  : widget.contact.contactId.id,
              style: tsHeading1.copiedWith(color: white).short,
              maxLines: 1,
            ),
          ),
          Container(
            child: CText(
              getCallStatus(session!.value.callState),
              style: tsBody2.copiedWith(color: white),
            ),
          ),
        ],
      );
}
