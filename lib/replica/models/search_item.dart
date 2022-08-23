import 'package:filesize/filesize.dart';
import 'package:lantern/common/ui/humanize_seconds.dart';
import 'package:lantern/replica/common.dart';

/// Defines the generic structure of a Replica search result
// TODO <08-08-22, kalli> This should reflect the title/filename decisions
class ReplicaSearchItem {
  ReplicaSearchItem(
    this.displayName,
    this.primaryMimeType,
    this.humanizedLastModified,
    this.humanizedFileSize,
    this.replicaLink,
    this.description,
  );

  String? primaryMimeType;
  String humanizedLastModified;
  String humanizedFileSize;
  late ReplicaLink replicaLink;
  late String displayName;
  late String description;

  static List<ReplicaSearchItem> fromJson(
    SearchCategory category,
    Map<String, dynamic> body,
  ) {
    var serverError = body['error'];
    if (serverError != null) {
      logger.e(serverError);
    }

    var items = <ReplicaSearchItem>[];
    var results = body['objects'] as List<dynamic>;
    for (var result in results) {
      try {
        // Can't continue if replicaLink is not there
        final link = ReplicaLink.New(result['replicaLink'] as String);
        if (link == null) {
          logger.w('Bad replicaLink: ${result['replicaLink'] as String}');
          continue;
        }

        // primaryMimeType is optional
        String? primaryMimeType;
        if (result.containsKey('mimeTypes') &&
            result['mimeTypes'] is List<dynamic> &&
            (result['mimeTypes'] as List<dynamic>)[0] is String &&
            ((result['mimeTypes'] as List<dynamic>)[0] as String).isNotEmpty) {
          primaryMimeType = (result['mimeTypes'] as List<dynamic>)[0] as String;
        }

        // displayName, lastModified and fileSize are always there
        final humanizedLastModified = DateTime.now()
            .difference(DateTime.parse(result['lastModified'] as String))
            .inSeconds
            .humanizeSeconds();
        final humanizedFileSize = filesize(result['fileSize'] as int);
        final displayName = link.displayName ?? result['displayName'];

        // TODO <08-11-22, kalli> Parse description from response
        final description = '';

        items.add(
          ReplicaSearchItem(
            displayName,
            primaryMimeType,
            humanizedLastModified,
            humanizedFileSize,
            link,
            description,
          ),
        );
      } catch (err) {
        logger.w(
          'Error parsing item ${result['replicaLink'] ??= '[invalid link]'}. Will ignore link',
        );
        continue;
      }
    }
    return items;
  }
}
