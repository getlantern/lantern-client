import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaVideoItem extends ReplicaSearchItem {
  ReplicaVideoItem(String displayName, ReplicaLink replicaLink)
      : super(replicaLink: replicaLink, displayName: displayName);

  static List<ReplicaVideoItem> fromJson(Map<String, dynamic> body) {
    var items = <ReplicaVideoItem>[];
    var results = body['objects'] as List<dynamic>;
    for (var result in results) {
      var link = ReplicaLink.New(result['replicaLink'] as String);
      if (link == null) {
        logger.w('Bad replicaLink: ${result['replicaLink'] as String}');
        continue;
      }
      items.add(ReplicaVideoItem(result['displayName'] as String, link));
    }
    return items;
  }
}
