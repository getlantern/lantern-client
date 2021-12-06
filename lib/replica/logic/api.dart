import 'package:http/http.dart' as http;
import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/replica/ui/searchcategory.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaApi {
  ReplicaApi(this.replicaHostAddr);
  final String replicaHostAddr;
  final _defaultTimeoutDuration = const Duration(seconds: 7);

  String getThumbnailAddr(ReplicaLink replicaLink, {String? overrideHostAddr}) {
    var hostAddr = overrideHostAddr ?? replicaHostAddr;
    return 'http://$hostAddr/replica/thumbnail?replicaLink=${replicaLink.toMagnetLink()}';
  }

  String getViewAddr(ReplicaLink replicaLink, {String? overrideHostAddr}) {
    var hostAddr = overrideHostAddr ?? replicaHostAddr;
    return 'http://$hostAddr/replica/view?link=${replicaLink.toMagnetLink()}';
  }

  String getDownloadAddr(ReplicaLink replicaLink, {String? overrideHostAddr}) {
    var hostAddr = overrideHostAddr ?? replicaHostAddr;
    return 'http://$hostAddr/replica/download?link=${replicaLink.toMagnetLink()}';
  }

  Future<SearchCategory> fetchCategoryFromReplicaLink(
      ReplicaLink replicaLink) async {
    var u = Uri.parse(getDownloadAddr(replicaLink));
    logger.v('XXX fetchCategoryFromReplicaLink: $u');

    try {
      var resp = await http.head(u).timeout(_defaultTimeoutDuration);
      if (resp.statusCode != 200) {
        throw Exception('fetching category from $u');
      }
      return SearchCategoryFromContentType(resp.headers['content-type']);
    } on TimeoutException catch (_) {
      // On a timeout, just return an unknown category
      return SearchCategory.Unknown;
    }
  }
}
