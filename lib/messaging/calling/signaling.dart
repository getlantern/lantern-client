import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';

enum SignalingState {
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

enum CallState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
}

/*
 * callbacks for Signaling API.
 */
typedef SignalingStateCallback = void Function(SignalingState state);
typedef CallStateCallback = void Function(Session session, CallState state);
typedef StreamStateCallback = void Function(
    Session? session, MediaStream stream);
typedef OtherEventCallback = void Function(dynamic event);

class Session {
  Session({required this.sid, required this.pid});

  String pid;
  String sid;
  RTCPeerConnection? pc;
  List<RTCIceCandidate> remoteCandidates = [];
}

class Signaling {
  Signaling({required this.mc, required this.onCallStateChange});

  final JsonEncoder _encoder = const JsonEncoder();
  final JsonDecoder _decoder = const JsonDecoder();
  final MethodChannel mc;
  dynamic _turnCredential;
  final Map<String, Session> _sessions = {};
  MediaStream? _localStream;
  final List<MediaStream> _remoteStreams = <MediaStream>[];

  CallStateCallback onCallStateChange;
  StreamStateCallback? onLocalStream;
  StreamStateCallback? onAddRemoteStream;
  StreamStateCallback? onRemoveRemoteStream;

  String get sdpSemantics =>
      WebRTC.platformIsWindows ? 'plan-b' : 'unified-plan';

  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      /*
       * turn server configuration example.
      {
        'url': 'turn:123.45.67.89:3478',
        'username': 'change_to_real_user',
        'credential': 'change_to_real_secret'
      },
      */
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ]
  };

  final Map<String, dynamic> _dcConstraints = {
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

  void muteMic() {
    if (_localStream != null) {
      var enabled = _localStream!.getAudioTracks()[0].enabled;
      _localStream!.getAudioTracks()[0].enabled = !enabled;
    }
  }

  Future<Session> call(String peerId, String media) async {
    var sessionId =
        peerId; // TODO: do we need to be able to have multiple sessions with the same peer?
    var session = await _createSession(
        peerId: peerId, sessionId: sessionId, media: media);
    _sessions[sessionId] = session;
    await _createOffer(session, media);
    onCallStateChange(session, CallState.CallStateNew);
    return session;
  }

  void bye(Session session) {
    _send(session.pid, 'bye', {
      'session_id': session.sid,
    });

    onCallStateChange(session, CallState.CallStateBye);
    _closeSession(_sessions[session.sid]);
  }

  void onMessage(String peerId, String messageJson) async {
    Map<String, dynamic> mapData = _decoder.convert(messageJson);
    var data = mapData['data'];

    switch (mapData['type']) {
      case 'offer':
        {
          var description = data['description'];
          var media = data['media'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          // TODO: need to "ring" the user first and only create the session
          // once the user accepts the call
          var newSession = await _createSession(
              session: session,
              peerId: peerId,
              sessionId: sessionId,
              media: media);
          _sessions[sessionId] = newSession;
          await newSession.pc!.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
          await _createAnswer(newSession, media);
          if (newSession.remoteCandidates.isNotEmpty) {
            newSession.remoteCandidates.forEach((candidate) async {
              await newSession.pc!.addCandidate(candidate);
            });
            newSession.remoteCandidates.clear();
          }
          onCallStateChange(newSession, CallState.CallStateNew);
        }
        break;
      case 'answer':
        {
          var description = data['description'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          await session?.pc?.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
        }
        break;
      case 'candidate':
        {
          var candidateMap = data['candidate'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          var candidate = RTCIceCandidate(candidateMap['candidate'],
              candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);

          if (session != null) {
            if (session.pc != null) {
              await session.pc!.addCandidate(candidate);
            } else {
              session.remoteCandidates.add(candidate);
            }
          } else {
            _sessions[sessionId] = Session(pid: peerId, sid: sessionId)
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
            onCallStateChange(session, CallState.CallStateBye);
          }
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

  Future<void> connect() async {
    if (_turnCredential == null) {
      try {
        _turnCredential = await getTurnCredential('demo.cloudwebrtc.com', 8086);
        /*{
            "username": "1584195784:mbzrxpgjys",
            "password": "isyl6FF6nqMTB9/ig5MrMRUXqZg",
            "ttl": 86400,
            "uris": ["turn:127.0.0.1:19302?transport=udp"]
          }
        */
        _iceServers = {
          'iceServers': [
            {
              'urls': _turnCredential['uris'][0],
              'username': _turnCredential['username'],
              'credential': _turnCredential['password']
            },
          ]
        };
      } catch (e) {}
    }
  }

  Future<Map> getTurnCredential(String host, int port) async {
    var url =
        'https://$host:$port/api/turn?service=turn&username=flutter-webrtc';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      print('getTurnCredential:response => $data.');
      return data;
    }
    return {};
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

    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    onLocalStream?.call(null, stream);
    return stream;
  }

  Future<Session> _createSession(
      {Session? session,
      required String peerId,
      required String sessionId,
      required String media}) async {
    var newSession = session ?? Session(sid: sessionId, pid: peerId);
    _localStream = await createStream();
    print(_iceServers);
    RTCPeerConnection pc = await createPeerConnection({
      ..._iceServers,
      ...{'sdpSemantics': sdpSemantics}
    }, _config);
    switch (sdpSemantics) {
      case 'plan-b':
        pc.onAddStream = (MediaStream stream) {
          onAddRemoteStream?.call(newSession, stream);
          _remoteStreams.add(stream);
        };
        await pc.addStream(_localStream!);
        break;
      case 'unified-plan':
        // Unified-Plan
        pc.onTrack = (event) {
          if (event.track.kind == 'video') {
            onAddRemoteStream?.call(newSession, event.streams[0]);
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
    pc.onIceCandidate = (candidate) {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      _send(peerId, 'candidate', {
        'candidate': {
          'sdpMLineIndex': candidate.sdpMlineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
        'session_id': sessionId,
      });
    };

    pc.onIceConnectionState = (state) {};

    pc.onRemoveStream = (stream) {
      onRemoveRemoteStream?.call(newSession, stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    newSession.pc = pc;
    return newSession;
  }

  Future<void> _createOffer(Session session, String media) async {
    try {
      RTCSessionDescription s =
          await session.pc!.createOffer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(s);
      await _send(session.pid, 'offer', {
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': session.sid,
        'media': media,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _createAnswer(Session session, String media) async {
    try {
      RTCSessionDescription s =
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
    var request = Map();
    request["type"] = event;
    request["data"] = data;
    await mc.invokeMethod('sendSignal', {
      'recipientId': peerId,
      'content': _encoder.convert(request),
    });
  }

  Future<void> _cleanSessions() async {
    if (_localStream != null) {
      _localStream!.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localStream!.dispose();
      _localStream = null;
    }
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
      onCallStateChange.call(session, CallState.CallStateBye);
    }
  }

  Future<void> _closeSession(Session? session) async {
    _localStream?.getTracks().forEach((element) async {
      await element.stop();
    });
    await _localStream?.dispose();
    _localStream = null;

    await session?.pc?.close();
  }
}
