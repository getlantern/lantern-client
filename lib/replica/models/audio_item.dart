import 'package:filesize/filesize.dart';
import 'package:lantern/common/ui/humanize.dart';
import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaAudioItem extends ReplicaSearchItem {
  ReplicaAudioItem(
      String displayName,
      this.primaryMimeType,
      this.humanizedLastModified,
      this.humanizedFileSize,
      ReplicaLink replicaLink)
      : super(replicaLink: replicaLink, displayName: displayName);
  String primaryMimeType;
  String humanizedLastModified;
  String humanizedFileSize;

  static List<ReplicaAudioItem> fromJson(Map<String, dynamic> body) {
    var items = <ReplicaAudioItem>[];
    var results = body['objects'] as List<dynamic>;
    for (var result in results) {
      try {
        var displayName = result['displayName'] as String;
        var primaryMimeType = result['mimeTypes'][0] as String;
        var link = ReplicaLink.New(result['replicaLink'] as String);
        if (link == null) {
          logger.w('Bad replicaLink: ${result['replicaLink'] as String}');
          continue;
        }
        var humanizedLastModified = DateTime.now()
            .difference(DateTime.parse(result['lastModified'] as String))
            .inSeconds
            .humanizeSeconds();
        var humanizedFileSize = filesize(result['fileSize'] as int);
        items.add(ReplicaAudioItem(displayName, primaryMimeType,
            humanizedLastModified, humanizedFileSize, link));
      } catch (err) {
        throw Exception(
            'parsing ${result['replicaLink'] ??= '[invalid link]'}');
      }
    }
    return items;
  }
}
