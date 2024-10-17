//import 'package:lantern/features/messaging/calls/signaling.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /*
  group('forceOpus()', () {
    test('opus available, force', () {
      final expected = sdp
          .replaceFirst(
            'm=audio 9 UDP/TLS/RTP/SAVPF 111 103 104 9 102 0 8 106 105 13 110 112 113 126',
            'm=audio 9 UDP/TLS/RTP/SAVPF 111',
          )
          .replaceFirst('a=rtcp-fb:111 transport-cc', 'a=rtcp-fb:111 nack')
          .replaceFirst(
            'a=fmtp:111 minptime=10;useinbandfec=1',
            'a=fmtp:111 maxplaybackrate=8000; sprop-maxcapturerate=8000; maxaveragebitrate=20000; stereo=0; sprop-stereo=0; useinbandfec=0; usedtx=0;\na=ptime:3',
          );
      expect(tuneOpus(sdp, force: true), expected);
    });
    test('opus available, no force', () {
      final expected = sdp
          .replaceFirst('a=rtcp-fb:111 transport-cc', 'a=rtcp-fb:111 nack')
          .replaceFirst(
            'a=fmtp:111 minptime=10;useinbandfec=1',
            'a=fmtp:111 maxplaybackrate=8000; sprop-maxcapturerate=8000; maxaveragebitrate=20000; stereo=0; sprop-stereo=0; useinbandfec=0; usedtx=0;\na=ptime:3',
          );
      expect(tuneOpus(sdp, force: false), expected);
    });
    test('opus not available', () {
      final sdpWithoutOpus = sdp.replaceFirst('a=rtpmap:111 opus/48000/2', '');
      expect(tuneOpus(sdpWithoutOpus, force: true), sdpWithoutOpus);
    });
    test('no audio', () {
      final sdpWithoutAudio = sdp.replaceFirst(
        'm=audio 9 UDP/TLS/RTP/SAVPF 111 103 104 9 102 0 8 106 105 13 110 112 113 126',
        '',
      );
      expect(tuneOpus(sdpWithoutAudio, force: true), sdpWithoutAudio);
    });
  });
   */
}

final sdp = '''
v=0
o=- 2068539952123632627 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=extmap-allow-mixed
a=msid-semantic: WMS 3d22dc0c-322a-468e-8005-dc765b292716
m=audio 9 UDP/TLS/RTP/SAVPF 111 103 104 9 102 0 8 106 105 13 110 112 113 126
c=IN IP4 0.0.0.0
a=rtcp:9 IN IP4 0.0.0.0
a=ice-ufrag:3LZR
a=ice-pwd:DH60fuDtQ+FX75XoMGUAaH8b
a=ice-options:trickle renomination
a=fingerprint:sha-256 1A:27:C7:5E:C3:31:A3:57:47:B5:AF:96:FA:85:B7:B9:93:58:92:A7:9B:FE:96:CA:1A:65:8E:B9:DF:E2:EF:68
a=setup:actpass
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:3 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:4 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:5 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:6 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=sendrecv
a=msid:3d22dc0c-322a-468e-8005-dc765b292716 e5cb26b1-987c-446a-8d8b-bbcbdbe622d3
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=rtcp-fb:111 transport-cc
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:102 ILBC/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=ssrc:2940270881 cname:ey2CjtQXDyTlX5nX
a=ssrc:2940270881 msid:3d22dc0c-322a-468e-8005-dc765b292716 e5cb26b1-987c-446a-8d8b-bbcbdbe622d3
a=ssrc:2940270881 mslabel:3d22dc0c-322a-468e-8005-dc765b292716
a=ssrc:2940270881 label:e5cb26b1-987c-446a-8d8b-bbcbdbe622d3
''';
