import 'package:flutter/widgets.dart';
import 'package:lantern/common/notifications.dart';
import 'package:lantern/common/round_button.dart';
import 'package:lantern/common/show_alert_dialog.dart';
import 'package:lantern/messaging/calls/signaling.dart';
import 'package:lantern/messaging/conversation/message_utils.dart';
import 'package:lantern/messaging/messaging_model.dart';
import 'package:lantern/model/protos_flutteronly/messaging.pb.dart';
import 'package:lantern/package_store.dart';

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
            showAlertDialog(
                context: context,
                title:
                    Text('unable_to_complete_call'.i18n, style: tsDialogTitle),
                content: Text('please_try_again'.i18n, style: tsDialogBody),
                agreeText: 'close'.i18n,
                agreeAction: () async {
                  signaling.bye(await session);
                });
          });
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 3,
                    child: Column(
                      children: [
                        renderContactAvatar(
                            displayName: widget.contact.displayName,
                            customColor: grey5),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 10),
                          child: Text(
                            widget.contact.displayName.isNotEmpty
                                ? sanitizeContactName(
                                    widget.contact.displayName)
                                : widget.contact.contactId.id,
                            style: TextStyle(color: white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 10),
                          child: Text(
                            signaling.value.callState == CallState.Connected
                                ? 'connected'.i18n
                                : 'Connecting...'.i18n,
                            style: TextStyle(color: white, fontSize: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RoundButton(
                          icon: CustomAssetImage(
                              path: ImagePaths.speaker_icon,
                              color: signalingState.speakerphoneOn
                                  ? grey5
                                  : white),
                          backgroundColor:
                              signalingState.speakerphoneOn ? white : grey5,
                          onPressed: () {
                            signaling.toggleSpeakerphone();
                          },
                        ),
                        RoundButton(
                          icon: CustomAssetImage(
                              path: ImagePaths.mute_icon,
                              color: signalingState.muted ? grey5 : white),
                          backgroundColor: signalingState.muted ? white : grey5,
                          onPressed: () {
                            signaling.toggleMute();
                          },
                        ),
                        RoundButton(
                          icon: const CustomAssetImage(
                              path: ImagePaths.hangup_icon),
                          backgroundColor: indicatorRed,
                          onPressed: () async {
                            signaling.bye(await session);
                          },
                        ),
                      ]),
                ],
              ),
            ),
          );
        });
  }
}
