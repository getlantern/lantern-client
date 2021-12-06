import 'package:flutter_test/flutter_test.dart';
import 'package:lantern/replica/logic/replica_link.dart';

class TestCase {
  TestCase(
      {required this.title, required this.input, required this.expectedOutput});
  String title;
  String input;
  ReplicaLink? expectedOutput;
}

void main() {
  test('value should start at 0', () {
    var cases = [
      TestCase(
          title: 'Encoded link',
          input:
              'magnet%3A%3Fxt%3Durn%3Abtih%3Ae380a6c5ae0fb15f296d29964a56250780b05ad7%26dn%3DWillisEarlBeal-BitTorrent%2FWho_is_Willis_Earl_Beal.pdf%26so%3D6',
          expectedOutput: ReplicaLink(
              infohash: 'e380a6c5ae0fb15f296d29964a56250780b05ad7',
              displayName:
                  'WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf',
              fileIndex: 6)),
      TestCase(
          title: 'Decoded link',
          input:
              'magnet:?xt=urn:btih:e380a6c5ae0fb15f296d29964a56250780b05ad7&dn=WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf&so=6',
          expectedOutput: ReplicaLink(
              infohash: 'e380a6c5ae0fb15f296d29964a56250780b05ad7',
              displayName:
                  'WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf',
              fileIndex: 6)),
      TestCase(
          title: 'Decoded link with replica prefix',
          input:
              'replica://magnet:?xt=urn:btih:e380a6c5ae0fb15f296d29964a56250780b05ad7&dn=WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf&so=6',
          expectedOutput: ReplicaLink(
              infohash: 'e380a6c5ae0fb15f296d29964a56250780b05ad7',
              displayName:
                  'WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf',
              fileIndex: 6)),
      TestCase(
          title: 'Hash',
          input: 'e380a6c5ae0fb15f296d29964a56250780b05ad7',
          expectedOutput: ReplicaLink(
              infohash: 'e380a6c5ae0fb15f296d29964a56250780b05ad7')),
      TestCase(
          title: 'Hash with replica prefix',
          input: 'replica://e380a6c5ae0fb15f296d29964a56250780b05ad7',
          expectedOutput: ReplicaLink(
              infohash: 'e380a6c5ae0fb15f296d29964a56250780b05ad7')),
      TestCase(title: 'Empty', input: '', expectedOutput: null),
      TestCase(
          title: 'Just replica prefix',
          input: 'replica://',
          expectedOutput: null),
      TestCase(title: 'bad', input: 'bunnyfoofoo', expectedOutput: null),
      TestCase(
          title: 'half a hash',
          input: 'replica://magnet:?xt=urn:btih:e380a6c5ae0fb15',
          expectedOutput: null),
    ];

    for (var c in cases) {
      var actualOutput = ReplicaLink.New(c.input);
      expect(actualOutput?.displayName, equals(c.expectedOutput?.displayName),
          reason: c.title);
      expect(actualOutput?.fileIndex, equals(c.expectedOutput?.fileIndex),
          reason: c.title);
      expect(actualOutput?.infohash, equals(c.expectedOutput?.infohash),
          reason: c.title);
    }
  });

  // test('value should be incremented', () {
  //   final counter = Counter();

  //   counter.increment();

  //   expect(counter.value, 1);
  // });

  // test('value should be decremented', () {
  //   final counter = Counter();

  //   counter.decrement();

  //   expect(counter.value, -1);
  // });
}
