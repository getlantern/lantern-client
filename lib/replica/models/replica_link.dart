class ReplicaLink {
  String? displayName;
  String? exactSource;
  int? fileIndex;
  late String infohash;

  ReplicaLink(
      {required this.infohash,
      this.displayName,
      this.fileIndex,
      this.exactSource});

  // A replica link doesn't need to have the prefix 'replica://'
  //
  // Types of acceptable replica links (after url unescaping):
  // - Prefixed with 'magnet:xt=urn:btih:<40-HEX-CHAR>'
  //   - magnet:?xt=urn:btih:e380a6c5ae0fb15f296d29964a56250780b05ad7&dn=WillisEarlBeal-BitTorrent/Who_is_Willis_Earl_Beal.pdf&so=6
  // - Is a '<40-HEX-CHAR>'
  //   - replica://e380a6c5ae0fb15f296d29964a56250780b05ad7
  static ReplicaLink? New(String s) {
    var parseMethod1 = () {
      var regexp = RegExp(r'^magnet:\?xt=urn:btih:([0-9a-fA-F]{40}).*');
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
            fileIndex: so);
      }
      return null;
    };
    var parseMethod2 = () {
      var regexp = RegExp(r'^[0-9a-fA-F]{40}');
      if (regexp.hasMatch(s)) {
        return ReplicaLink(infohash: s);
      }
      return null;
    };

    s = Uri.decodeQueryComponent(s);
    s = s.replaceAll('replica://', '');
    for (var method in [parseMethod1, parseMethod2]) {
      var rl = method();
      if (rl != null) {
        return rl;
      }
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
