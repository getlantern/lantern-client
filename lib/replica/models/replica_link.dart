class ReplicaLink {
  static final regexp = RegExp(r'^magnet:\?xt=urn:btih:([0-9a-fA-F]{40}).*');

  String? displayName;
  String? exactSource;
  int? fileIndex;
  late String infohash;

  ReplicaLink({
    required this.infohash,
    this.displayName,
    this.fileIndex,
    this.exactSource,
  });

  // Only this link type is accepted:
  // - Prefixed with 'magnet:xt=urn:btih:<40-HEX-CHAR>'
  //   - replica://magnet:?xt=urn:btih:e380a6c5ae0fb15f296d29964a56250780b05ad7&dn=WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf&so=6
  //     - The 'replica://' prefix is optional
  //
  // XXX <16-12-21, soltzen> There was a discussion to allow
  // 'replica://<40-HEX-CHAR>' as a possible schema. This was removed since clients will not carry expected parameters (e.g., so, dn, xs).
  // See here for the structure of a replica link:
  // https://github.com/getlantern/replica-docs/blob/d1c5c3757180eab42d76a7798914bf6049cee4d3/LINKS.md
  static ReplicaLink? New(String s) {
    var parseLink = () {
      if (regexp.hasMatch(s)) {
        var u = Uri.parse(s);
        var so = 0;
        if (u.queryParameters['so'] != null) {
          so = int.parse(u.queryParameters['so']!);
        }
        var firstMatch = regexp.firstMatch(s);
        if (firstMatch == null) {
          return null;
        }
        var infohash = firstMatch[1];
        if (infohash == null) {
          return null;
        }
        return ReplicaLink(
          infohash: infohash,
          displayName: u.queryParameters['dn'],
          exactSource: u.queryParameters['xs'],
          fileIndex: so,
        );
      }
      return null;
    };

    s = Uri.decodeQueryComponent(s);
    s = s.replaceAll('replica://', '');
    var rl = parseLink();
    if (rl != null) {
      return rl;
    }
    return null;
  }

  String toMagnetLink() {
    var s = 'magnet:?xt=urn:btih:$infohash';
    if (exactSource != null) {
      s += '&xs=$exactSource';
    }
    if (displayName != null) {
      s += '&dn=$displayName';
    }
    if (fileIndex != null) {
      s += '&so=$fileIndex';
    }
    // XXX <13-12-21, soltzen> Don't use Uri.encodeFull: Replica backend only
    // accepts this
    return Uri.encodeQueryComponent(s);
  }
}
