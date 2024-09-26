import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/features/replica/models/replica_link.dart';

class TestCase {
  TestCase({
    required this.title,
    required this.input,
    required this.expectedOutput,
  });

  String title;
  String input;
  ReplicaLink? expectedOutput;
}

// TODO <08-08-22, kalli> We might want to move this to integration tests and use our test driver library
void main() {
  test('', () {
    var cases = [
      TestCase(
        title: 'Encoded link',
        input:
            'magnet%3A%3Fxt%3Durn%3Abtih%3Ae380a6c5ae0fb15f296d29964a56250780b05ad7%26dn%3DWillisEarlBeal-BitTorrent%2FWho_is_Willis_Earl_Beal.pdf%26so%3D6',
        expectedOutput: ReplicaLink(
          infohash: 'e380a6c5ae0fb15f296d29964a56250780b05ad7',
          displayName: 'WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf',
          fileIndex: 6,
        ),
      ),
      TestCase(
        title: 'Decoded link',
        input:
            'magnet:?xt=urn:btih:e380a6c5ae0fb15f296d29964a56250780b05ad7&dn=WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf&so=6',
        expectedOutput: ReplicaLink(
          infohash: 'e380a6c5ae0fb15f296d29964a56250780b05ad7',
          displayName: 'WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf',
          fileIndex: 6,
        ),
      ),
      TestCase(
        title: 'Decoded link with replica prefix',
        input:
            'replica://magnet:?xt=urn:btih:e380a6c5ae0fb15f296d29964a56250780b05ad7&dn=WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf&so=6',
        expectedOutput: ReplicaLink(
          infohash: 'e380a6c5ae0fb15f296d29964a56250780b05ad7',
          displayName: 'WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf',
          fileIndex: 6,
        ),
      ),
      TestCase(title: 'Empty', input: '', expectedOutput: null),
      TestCase(
        title: 'Just replica prefix',
        input: 'replica://',
        expectedOutput: null,
      ),
      TestCase(title: 'bad', input: 'bunnyfoofoo', expectedOutput: null),
      TestCase(
        title: 'half a hash',
        input: 'replica://magnet:?xt=urn:btih:e380a6c5ae0fb15',
        expectedOutput: null,
      ),
      TestCase(
        title: 'regression 1',
        input:
            'magnet:?xt=urn:btih:7604cc90fb4c8636e574af27708284eef86de797&dn=%5BHD%5DAAA-141%2F%E8%AB%96%E5%A3%87%E6%96%87%E5%AE%A3%2F%E6%84%9B%E5%9C%A8%E9%BB%91%E5%A4%9C%40%E7%84%A1%E9%99%90%E8%A8%8E%E8%AB%96%E5%8D%80+FastZone.ORG.url&so=17',
        expectedOutput: ReplicaLink(
          infohash: '7604cc90fb4c8636e574af27708284eef86de797',
          displayName: Uri.decodeFull(
            '%5BHD%5DAAA-141/%E8%AB%96%E5%A3%87%E6%96%87%E5%AE%A3/%E6%84%9B%E5%9C%A8%E9%BB%91%E5%A4%9C@%E7%84%A1%E9%99%90%E8%A8%8E%E8%AB%96%E5%8D%80%20FastZone.ORG.url',
          ),
          fileIndex: 17,
        ),
      ),
    ];

    for (var c in cases) {
      var actualOutput = ReplicaLink.New(c.input);
      expect(
        actualOutput?.displayName,
        equals(c.expectedOutput?.displayName),
        reason: c.title,
      );
      expect(
        actualOutput?.fileIndex,
        equals(c.expectedOutput?.fileIndex),
        reason: c.title,
      );
      expect(
        actualOutput?.infohash,
        equals(c.expectedOutput?.infohash),
        reason: c.title,
      );
    }
  });
}
