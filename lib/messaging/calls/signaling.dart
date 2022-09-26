import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lantern/app.dart';
import 'package:lantern/messaging/messaging.dart';

import 'call.dart';

enum CallState {
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
  Session? session,
  MediaStream stream,
);
typedef OtherEventCallback = void Function(dynamic event);

class Session extends ValueNotifier<SignalingState> {
  Session({
    required this.signaling,
    required this.isInitiator,
    required this.sid,
    required this.pid,
  }) : super(SignalingState());

  Signaling signaling;
  bool isInitiator;
  String pid;
  String sid;
  RTCPeerConnection? pc;
  List<RTCIceCandidate> remoteCandidates = [];

  void toggleMute() {
    value.muted = !value.muted;
    signaling.setMute(value.muted);
    notifyListeners();
  }

  void toggleSpeakerphone() {
    value.speakerphoneOn = !value.speakerphoneOn;
    signaling.setSpeakerphoneOn(value.speakerphoneOn);
    notifyListeners();
  }

  void setCallState(CallState callState) {
    value.callState = callState;
    notifyListeners();
  }
}

class SignalingState {
  CallState callState = CallState.Ringing;
  var muted = false;
  var speakerphoneOn = false;
}

/// Code adapted from https://github.com/flutter-webrtc/flutter-webrtc-demo
class Signaling {
  Signaling(this.mc) {
    // pre-load ringing file into cache
    audioCache.load(ringingFile);
  }

  static final ringingFile = 'ringing.mp3';
  final AudioCache audioCache =
      AudioCache(prefix: 'assets/sounds/', fixedPlayer: AudioPlayer());
  bool audioPlayerOnSpeaker = true;
  bool audioPlayerInitialized = false;
  final JsonEncoder _encoder = const JsonEncoder();
  final JsonDecoder _decoder = const JsonDecoder();
  final MethodChannel mc;

  // Sessions keyed to peerId (this means that currently we only allow one
  // session per peer).
  final Map<String, Session> _sessions = {};
  MediaStream? _localStream;
  final List<MediaStream> _remoteStreams = <MediaStream>[];

  void setAudioPlayerOnSpeaker(bool speaker) async {
    if (speaker == audioPlayerOnSpeaker) {
      // no change required
      return;
    }

    if (audioPlayerInitialized) {
      await audioCache.fixedPlayer!.earpieceOrSpeakersToggle();
      audioPlayerOnSpeaker = speaker;
    }
  }

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

  void close() async {
    await _cleanSessions();
  }

  void switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void setMute(bool muted) {
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        Helper.setMicrophoneMute(muted, track);
      });
    }
  }

  void setSpeakerphoneOn(bool speakerphoneOn) {
    setAudioPlayerOnSpeaker(speakerphoneOn);
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enableSpeakerphone(speakerphoneOn);
      });
    }
  }

  Future<Session> call({
    required String peerId,
    required String media,
  }) async {
    // The first time we start ringing, the audio cache will not yet be initialized
    // so we wait to call audioPlayerOnSpeaker.
    final disableSpeakerImmediately = audioCache.fixedPlayer != null;
    if (disableSpeakerImmediately) {
      setAudioPlayerOnSpeaker(false);
    }
    await audioCache.loop(ringingFile);
    audioPlayerInitialized = true;
    if (!disableSpeakerImmediately) {
      setAudioPlayerOnSpeaker(false);
    }

    var sessionId =
        peerId; // TODO: do we need to be able to have multiple sessions with the same peer?
    var session = await _createSession(
      isInitiator: true,
      peerId: peerId,
      sessionId: sessionId,
      media: media,
    );
    _sessions[peerId] = session;
    await _createOffer(session, media);
    setSpeakerphoneOn(false);
    return session;
  }

  Future<void> bye(Session session) async {
    await audioCache.fixedPlayer!.stop();
    await _sendBye(session.pid, session.sid);
    session.setCallState(CallState.Bye);
    await _closeSession(_sessions[session.pid]);
  }

  Future<void> _sendBye(String peerId, String sessionId) async {
    await _send(peerId, 'bye', {
      'session_id': sessionId,
    });
  }

  Future<MediaStream> createStream() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': false,
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

    // var mediaDevices = await navigator.mediaDevices.enumerateDevices();
    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    // unmute all audio tracks
    stream.getAudioTracks().forEach((track) {
      track.enabled = true;
      Helper.setVolume(1, track);
    });
    return stream;
  }

  void onMessage(String peerId, String messageJson, bool acceptedCall) async {
    await audioCache.fixedPlayer!.stop();
    Map<String, dynamic> parsedMessage = _decoder.convert(messageJson);
    var data = parsedMessage['data'];
    switch (parsedMessage['type']) {
      case 'offer':
        {
          var description = data['description'];
          var media = data['media'];
          var sessionId = data['session_id'];

          // Only answer if user accepted call. This prevents the system from
          // transmitting audio or video without the user's knowledge.
          if (acceptedCall) {
            // close sessions from other peers
            for (var existingSession in _sessions.values) {
              if (existingSession.pid != peerId) {
                await bye(existingSession);
              }
            }

            // create new session for incoming call
            var newSession = await _createSession(
              isInitiator: false,
              session: _sessions[peerId],
              peerId: peerId,
              sessionId: sessionId,
              media: media,
            );
            _sessions[peerId] = newSession;
            await newSession.pc!.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']),
            );
            await _createAnswer(newSession, media);
            if (newSession.remoteCandidates.isNotEmpty) {
              newSession.remoteCandidates.forEach((candidate) async {
                await _addRemoteCandidate(newSession, candidate);
              });
              newSession.remoteCandidates.clear();
            }

            newSession.setCallState(CallState.Connected);

            var contact = await messagingModel.getDirectContact(peerId);
            await navigatorKey.currentContext?.pushRoute(
              FullScreenDialogPage(
                widget: Call(
                  contact: contact,
                  initialSession: newSession,
                ),
              ),
            );
          }
        }
        break;
      case 'answer':
        {
          var description = data['description'];
          var session = _sessions[peerId];
          session?.setCallState(CallState.Connected);
          await session?.pc?.setRemoteDescription(
            RTCSessionDescription(description['sdp'], description['type']),
          );
        }
        break;
      case 'candidate':
        {
          var candidateMap = data['candidate'];
          var candidateString = candidateMap['candidate'] as String;
          var sessionId = data['session_id'];
          var session = _sessions[peerId];
          var candidate = RTCIceCandidate(
            candidateString,
            candidateMap['sdpMid'],
            candidateMap['sdpMLineIndex'],
          );

          if (session != null) {
            if (session.pc != null) {
              await _addRemoteCandidate(session, candidate);
            } else {
              session.remoteCandidates.add(candidate);
            }
          } else {
            _sessions[peerId] = Session(
              signaling: this,
              isInitiator: false,
              pid: peerId,
              sid: sessionId,
            )..remoteCandidates.add(candidate);
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
          var session = _sessions.remove(peerId);
          if (session != null) {
            session.setCallState(CallState.Bye);
            await _closeSession(session);
          }
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

  Future<Session> _createSession({
    required bool isInitiator,
    Session? session,
    required String peerId,
    required String sessionId,
    required String media,
  }) async {
    var newSession = session ??
        Session(
          signaling: this,
          isInitiator: isInitiator,
          sid: sessionId,
          pid: peerId,
        );
    _localStream = await createStream();

    var pc = await createPeerConnection(
      {
        ..._iceServers,
        ...{
          'sdpSemantics': sdpSemantics,
          // 'iceTransportPolicy': 'relay',
        }
      },
      _config,
    );

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
    }

    pc.onIceCandidate = (candidate) async {
      // Only the initiator transmits candidates
      if (newSession.isInitiator && candidate.candidate != null) {
        // look specifically for localhost TCP candidates
        var candidateString = candidate.candidate!;
        var match = localTCPCandidateRegExp.firstMatch(candidateString);
        if (match != null) {
          var hostAndPort = match.group(1)!;
          var relayAddr = await messagingModel
              .allocateRelayAddress(hostAndPort.replaceFirst(' ', ':'));
          candidateString =
              candidateString.replaceFirst(hostAndPort, relayAddr);
          await _send(peerId, 'candidate', {
            'candidate': {
              'sdpMLineIndex': candidate.sdpMLineIndex,
              'sdpMid': candidate.sdpMid,
              'candidate': candidateString,
            },
            'session_id': sessionId,
          });
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
    Session session,
    RTCIceCandidate candidate,
  ) async {
    if (!session.isInitiator && candidate.candidate != null) {
      var match = remoteTCPCandidateRegExp.firstMatch(candidate.candidate!);
      if (match != null) {
        var relayAddr = match.group(1)!;
        var localRelayAddr = await messagingModel.relayTo(relayAddr);
        var localCandidate = RTCIceCandidate(
          candidate.candidate!
              .replaceFirst(relayAddr, localRelayAddr.replaceFirst(':', ' ')),
          candidate.sdpMid,
          candidate.sdpMLineIndex,
        );
        await session.pc!.addCandidate(localCandidate);
      }
    }
  }

  Future<void> _createOffer(Session session, String media) async {
    try {
      var s =
          await session.pc!.createOffer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(s);
      // Note - we only force opus on the caller side to avoid incompatibilities
      // between different versions of clients (i.e. if in the future we move
      // off opus as our default, old clients that preferred opus will still be
      // able to answer calls from new clients and vice versa).
      await _send(session.pid, 'offer', {
        'description': {'sdp': tuneOpus(s.sdp, force: true), 'type': s.type},
        'session_id': session.sid,
        'media': media,
      });
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
        'description': {'sdp': tuneOpus(s.sdp, force: false), 'type': s.type},
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
    _sessions.values.forEach((session) {
      session.pc?.close();
    });
    _sessions.clear();
  }

  void _closeSessionByPeerId(String peerId) {
    var session = _sessions.remove(peerId);
    if (session != null) {
      _closeSession(session);
      session.setCallState(CallState.Bye);
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

final rtpmapOpusRegex = RegExp(r'a=rtpmap:([0-9]+) opus.+');
final audioRegex = RegExp(r'm=audio ([0-9]+) ([^ ]+) .+');

/// Forces use of Opus and tweaks settings for lower bandwidth usage
/// See https://datatracker.ietf.org/doc/html/rfc7587 for details of using Opus
/// with RTP.
String? tuneOpus(String? sdp, {required bool force}) {
  if (sdp == null) {
    return null;
  }

  final opusMatch = rtpmapOpusRegex.firstMatch(sdp);
  if (opusMatch == null) {
    return sdp;
  }

  final audioMatch = audioRegex.firstMatch(sdp);
  if (audioMatch == null) {
    return sdp;
  }

  final opusId = opusMatch.group(1);
  final audioPort = audioMatch.group(1);
  final audioProtocol = audioMatch.group(2);

  if (force) {
    // use only opus
    sdp = sdp.replaceFirst(
      audioRegex,
      'm=audio $audioPort $audioProtocol $opusId',
    );
  }

  // Use simple nack feedback/congestion control since we're always running over
  // TCP anyway. I tried just turning this off completely by removing this line,
  // but that causes calls to fail. See here for some other possible values:
  // https://www.iana.org/assignments/sdp-parameters/sdp-parameters.xhtml#sdp-parameters-14
  sdp =
      sdp.replaceFirst(RegExp('a=rtcp-fb:$opusId.+'), 'a=rtcp-fb:$opusId nack');

  // set up custom opus parameters (8 KHz sampling, 20 kbps bitrate, mono, no
  // FEC, no DTX, small audio packet size.
  // Note - I couldn't get the maxptime parameter to work, it caused crashes.
  return sdp.replaceFirst(
    RegExp('a=fmtp:$opusId.+'),
    'a=fmtp:$opusId maxplaybackrate=8000; sprop-maxcapturerate=8000; maxaveragebitrate=20000; stereo=0; sprop-stereo=0; useinbandfec=0; usedtx=0;\na=ptime:3',
  );
}

/// This just removes the a=fmtp line for Opus, used on the receiving end.
String? removeOpusFMTP(String? sdp) {
  if (sdp == null) {
    return null;
  }

  final opusMatch = rtpmapOpusRegex.firstMatch(sdp);
  if (opusMatch == null) {
    return sdp;
  }

  final opusId = opusMatch.group(1);
  return sdp.replaceFirst(RegExp('a=fmtp:$opusId.+'), '');
}
