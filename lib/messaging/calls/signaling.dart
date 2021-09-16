import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lantern/app.dart';
import 'package:lantern/messaging/messaging.dart';

import 'call.dart';

enum CallState {
  New,
  Ringing,
  Connected,
  Bye,
}

final localTCPCandidateRegExp =
    RegExp(r'.+tcp [0-9]+ (127.0.0.1 [0-9]{1,5}).+');

final remoteTCPCandidateRegExp = RegExp(r'.+tcp [0-9]+ (ws[^\s]+).+');

/*
 * callbacks for Signaling API.
 */
typedef StreamStateCallback = void Function(
    Session? session, MediaStream stream);
typedef OtherEventCallback = void Function(dynamic event);

class Session {
  Session({required this.isInitiator, required this.sid, required this.pid});

  bool isInitiator;
  String pid;
  String sid;
  RTCPeerConnection? pc;
  List<RTCIceCandidate> remoteCandidates = [];
}

class SignalingState {
  CallState callState = CallState.New;
  var muted = false;
  var speakerphoneOn = false;
}

/// Code adapted from https://github.com/flutter-webrtc/flutter-webrtc-demo
class Signaling extends ValueNotifier<SignalingState>
    with WidgetsBindingObserver {
  Signaling({required this.model, required this.mc}) : super(SignalingState()) {
    WidgetsBinding.instance!.addObserver(this);
  }

  final JsonEncoder _encoder = const JsonEncoder();
  final JsonDecoder _decoder = const JsonDecoder();
  final MethodChannel mc;
  final Map<String, Session> _sessions = {};
  MediaStream? _localStream;
  final List<MediaStream> _remoteStreams = <MediaStream>[];
  final MessagingModel model;
  Function? closeAlertDialog;
  var visible = true;

  String get sdpSemantics =>
      WebRTC.platformIsWindows ? 'plan-b' : 'unified-plan';

  Map<String, dynamic> get _iceServers => {
        'iceServers': [
          // Note - we currently don't use STUN because it exposes clients' IP
          // addresses to each other.
          // {'url': 'stun:stun.l.google.com:19302'},
          // {
          //   'urls': 'turn:turn.getlantern.org:3478?transport=tcp',
          //   'username': 'lantern',
          //   'credential': 'IIs6WhQ1zE0lQJhfnFwE',
          // },
        ]
      };

  Map<String, dynamic> get _config => {
        'mandatory': {},
        'optional': [
          {'DtlsSrtpKeyAgreement': true},
        ]
      };

  Map<String, dynamic> get _dcConstraints => {
        'mandatory': {
          'OfferToReceiveAudio': false,
          'OfferToReceiveVideo': false,
        },
        'optional': [],
      };

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        visible = false;
        break;
      case AppLifecycleState.resumed:
        visible = true;
        break;
      default:
        break;
    }
  }

  void close() async {
    await _cleanSessions();
  }

  void switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void toggleMute() {
    value.muted = !value.muted;
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !value.muted;
      });
    }
    notifyListeners();
  }

  void toggleSpeakerphone() {
    value.speakerphoneOn = !value.speakerphoneOn;
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enableSpeakerphone(value.speakerphoneOn);
      });
    }
    notifyListeners();
  }

  Future<Session> call(
      {required String peerId,
      required String media,
      required Function() onError}) async {
    var sessionId =
        peerId; // TODO: do we need to be able to have multiple sessions with the same peer?
    var session = await _createSession(
        isInitiator: true, peerId: peerId, sessionId: sessionId, media: media);
    _sessions[sessionId] = session;
    await _createOffer(session, media, onError);
    value.muted = false;
    value.speakerphoneOn = false;
    value.callState = CallState.Ringing;
    notifyListeners();
    return session;
  }

  void bye(Session session) {
    _sendBye(session.pid, session.sid);

    value.callState = CallState.Bye;
    notifyListeners();
    _closeSession(_sessions[session.sid]);
  }

  void _sendBye(String peerId, String sessionId) {
    _send(peerId, 'bye', {
      'session_id': sessionId,
    });
  }

  Future<MediaStream> createStream() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      // 'video': {
      //   'mandatory': {
      //     'minWidth':
      //         '640', // Provide your own width, height and frame rate here
      //     'minHeight': '480',
      //     'minFrameRate': '30',
      //   },
      //   'facingMode': 'user',
      //   'optional': [],
      // }
    };

    var mediaDevices = await navigator.mediaDevices.enumerateDevices();
    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    // unmute all audio tracks and disable speakerphone by default
    stream.getAudioTracks().forEach((track) {
      track.enabled = true;
      track.enableSpeakerphone(false);
    });
    return stream;
  }

  void onMessage(String peerId, String messageJson, {bool ring = true}) async {
    Map<String, dynamic> parsedMessage = _decoder.convert(messageJson);
    var data = parsedMessage['data'];

    switch (parsedMessage['type']) {
      case 'offer':
        {
          var description = data['description'];
          var media = data['media'];
          var sessionId = data['session_id'];

          // IMPORTANT - instead of immediately accepting the offer, we first
          // prompt the user. This prevents the system from transmitting audio
          // or video without the user's knowledge.
          var contact = await model.getDirectContact(peerId);
          if (ring) {
            unawaited(FlutterRingtonePlayer.playRingtone());
          }
          if (!visible) {
            // show ringer as a system notification
            await notifications.showRingingNotification(
                contact, peerId, messageJson);
            return;
          }
          closeAlertDialog?.call();
          closeAlertDialog = showAlertDialog(
              context: navigatorKey.currentContext!,
              autoDismissAfter: const Duration(seconds: 30),
              // force dismissal through actual dismiss action to make sure we stop ringtone, etc
              barrierDismissible: false,
              title: CText('incoming_call'.i18n, style: tsBody14),
              content: CTextWrap('call_from'.i18n.fill([contact.displayName]),
                  style: tsBody14),
              dismissText: 'dismiss'.i18n,
              dismissAction: () async {
                await FlutterRingtonePlayer.stop();
                _sendBye(peerId, sessionId);
              },
              agreeAction: () async {
                await FlutterRingtonePlayer.stop();
                var newSession = await _createSession(
                    isInitiator: false,
                    session: _sessions[sessionId],
                    peerId: peerId,
                    sessionId: sessionId,
                    media: media);
                _sessions[sessionId] = newSession;
                await newSession.pc!.setRemoteDescription(RTCSessionDescription(
                    description['sdp'], description['type']));
                await _createAnswer(newSession, media);
                if (newSession.remoteCandidates.isNotEmpty) {
                  newSession.remoteCandidates.forEach((candidate) async {
                    await _addRemoteCandidate(newSession, candidate);
                  });
                  newSession.remoteCandidates.clear();
                }

                value.callState = CallState.Connected;
                notifyListeners();

                await navigatorKey.currentContext?.pushRoute(
                  FullScreenDialogPage(
                      widget: Call(
                    contact: contact,
                    model: model,
                    initialSession: newSession,
                  )),
                );
              });
        }
        break;
      case 'answer':
        {
          var description = data['description'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];

          value.muted = false;
          value.speakerphoneOn = false;
          value.callState = CallState.Connected;
          notifyListeners();

          await session?.pc?.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
        }
        break;
      case 'candidate':
        {
          var candidateMap = data['candidate'];
          var candidateString = candidateMap['candidate'] as String;
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          var candidate = RTCIceCandidate(candidateString,
              candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);

          if (session != null) {
            if (session.pc != null) {
              await _addRemoteCandidate(session, candidate);
            } else {
              session.remoteCandidates.add(candidate);
            }
          } else {
            _sessions[sessionId] =
                Session(isInitiator: false, pid: peerId, sid: sessionId)
                  ..remoteCandidates.add(candidate);
          }
        }
        break;
      case 'leave':
        {
          var peerId = data as String;
          _closeSessionByPeerId(peerId);
        }
        break;
      case 'bye':
        {
          var sessionId = data['session_id'];
          print('bye: ' + sessionId);
          var session = _sessions.remove(sessionId);
          if (session != null) {
            value.callState = CallState.Bye;
            notifyListeners();
          }
          closeAlertDialog?.call();
          unawaited(FlutterRingtonePlayer.stop());
          unawaited(_closeSession(session));
        }
        break;
      case 'keepalive':
        {
          print('keepalive response!');
        }
        break;
      default:
        break;
    }
  }

  Future<Session> _createSession(
      {required bool isInitiator,
      Session? session,
      required String peerId,
      required String sessionId,
      required String media}) async {
    var newSession = session ??
        Session(isInitiator: isInitiator, sid: sessionId, pid: peerId);
    _localStream = await createStream();
    var pc = await createPeerConnection({
      ..._iceServers,
      ...{
        'sdpSemantics': sdpSemantics,
        // 'iceTransportPolicy': 'relay',
      }
    }, _config);
    switch (sdpSemantics) {
      case 'plan-b':
        pc.onAddStream = (MediaStream stream) {
          // onAddRemoteStream?.call(newSession, stream);
          _remoteStreams.add(stream);
        };
        await pc.addStream(_localStream!);
        break;
      case 'unified-plan':
        // Unified-Plan
        pc.onTrack = (event) {
          if (event.track.kind == 'video') {
            // onAddRemoteStream?.call(newSession, event.streams[0]);
          }
        };
        _localStream!.getTracks().forEach((track) {
          pc.addTrack(track, _localStream!);
        });
        break;

      // Unified-Plan: Simulcast
      /*
      await pc.addTransceiver(
        track: _localStream.getAudioTracks()[0],
        init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly, streams: [_localStream]),
      );

      await pc.addTransceiver(
        track: _localStream.getVideoTracks()[0],
        init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly,
            streams: [
              _localStream
            ],
            sendEncodings: [
              RTCRtpEncoding(rid: 'f', active: true),
              RTCRtpEncoding(
                rid: 'h',
                active: true,
                scaleResolutionDownBy: 2.0,
                maxBitrate: 150000,
              ),
              RTCRtpEncoding(
                rid: 'q',
                active: true,
                scaleResolutionDownBy: 4.0,
                maxBitrate: 100000,
              ),
            ]),
      );*/
      /*
        var sender = pc.getSenders().find(s => s.track.kind == "video");
        var parameters = sender.getParameters();
        if(!parameters)
          parameters = {};
        parameters.encodings = [
          { rid: "h", active: true, maxBitrate: 900000 },
          { rid: "m", active: true, maxBitrate: 300000, scaleResolutionDownBy: 2 },
          { rid: "l", active: true, maxBitrate: 100000, scaleResolutionDownBy: 4 }
        ];
        sender.setParameters(parameters);
      */
    }
    pc.onIceCandidate = (candidate) async {
      // Only the initiator transmits candidates
      if (newSession.isInitiator && candidate.candidate != null) {
        // look specifically for localhost TCP candidates
        var candidateString = candidate.candidate!;
        var match = localTCPCandidateRegExp.firstMatch(candidateString);
        if (match != null) {
          var hostAndPort = match.group(1)!;
          var relayAddr = await model
              .allocateRelayAddress(hostAndPort.replaceFirst(' ', ':'));
          candidateString =
              candidateString.replaceFirst(hostAndPort, relayAddr);
          unawaited(_send(peerId, 'candidate', {
            'candidate': {
              'sdpMLineIndex': candidate.sdpMlineIndex,
              'sdpMid': candidate.sdpMid,
              'candidate': candidateString,
            },
            'session_id': sessionId,
          }));
        }
      }
    };

    pc.onIceConnectionState = (state) {};

    pc.onRemoveStream = (stream) {
      // onRemoveRemoteStream?.call(newSession, stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    newSession.pc = pc;
    return newSession;
  }

  Future<void> _addRemoteCandidate(
      Session session, RTCIceCandidate candidate) async {
    if (!session.isInitiator && candidate.candidate != null) {
      var match = remoteTCPCandidateRegExp.firstMatch(candidate.candidate!);
      if (match != null) {
        var relayAddr = match.group(1)!;
        var localRelayAddr = await model.relayTo(relayAddr);
        var localCandidate = RTCIceCandidate(
          candidate.candidate!
              .replaceFirst(relayAddr, localRelayAddr.replaceFirst(':', ' ')),
          candidate.sdpMid,
          candidate.sdpMlineIndex,
        );
        await session.pc!.addCandidate(localCandidate);
      }
    }
  }

  Future<void> _createOffer(
      Session session, String media, Function() onError) async {
    try {
      var s =
          await session.pc!.createOffer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(s);
      unawaited(_send(session.pid, 'offer', {
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': session.sid,
        'media': media,
      }).onError((error, stackTrace) => onError()));
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _createAnswer(Session session, String media) async {
    try {
      var s =
          await session.pc!.createAnswer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(s);
      await _send(session.pid, 'answer', {
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': session.sid,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _send(peerId, event, data) async {
    var request = {};
    request['type'] = event;
    request['data'] = data;
    await mc.invokeMethod('sendSignal', {
      'recipientId': peerId,
      'content': _encoder.convert(request),
    });
  }

  Future<void> _cleanSessions() async {
    _sessions.forEach((key, sess) async {
      await sess.pc?.close();
    });
    _sessions.clear();
  }

  void _closeSessionByPeerId(String peerId) {
    var session;
    _sessions.removeWhere((String key, Session sess) {
      var ids = key.split('-');
      session = sess;
      return peerId == ids[0] || peerId == ids[1];
    });
    if (session != null) {
      _closeSession(session);
      value.callState = CallState.Bye;
      notifyListeners();
    }
  }

  Future<void> _closeSession(Session? session) async {
    _localStream?.getTracks().forEach((track) async {
      await track.stop();
    });
    await _localStream?.dispose();
    _localStream = null;
    await session?.pc?.close();
  }
}
