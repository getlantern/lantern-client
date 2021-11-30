import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaImageItem extends ReplicaSearchItem {
  ReplicaImageItem(String displayName, ReplicaLink replicaLink)
      : super(replicaLink: replicaLink, displayName: displayName);

  static List<ReplicaImageItem> fromJson(Map<String, dynamic> body) {
    var items = <ReplicaImageItem>[];
    var results = body['objects'] as List<dynamic>;
    for (var result in results) {
      var link = ReplicaLink.New(result['replicaLink'] as String);
      if (link == null) {
        logger.w('Bad replicaLink: ${result['replicaLink'] as String}');
        continue;
      }
      items.add(ReplicaImageItem(result['displayName'] as String, link));
    }
    return items;
  }
}
