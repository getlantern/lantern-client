import 'package:filesize/filesize.dart';
import 'package:lantern/common/ui/humanize_seconds.dart';
import 'package:lantern/replica/common.dart';

/// Defines the generic structure of a Replica search result
/// The server returns a { metadata: {title}, {description}} field in its response. It's a bit redundant since we can get that same info (+ the creationDate field) via the `/object_info` endpoint. We are rendering the title and description returned as part of ReplicaSearchItem in the Results views and requesting the same info again from the `/object_info` endpoint when we are viewing a specific replicaLink in one of the Viewers.
/// There is also a {displayName} field returned in the ReplicaSearchItem, which corresponds to the file name at the moment of its upload.
/// We will be using the following notation to disambiguate:
/// ReplicaSearchItem: {metadata: {title}, {description}} -> metaTitle, metaDescription
/// Viewer: {title, description, creationDate} returned from `/object_info` -> infoTitle, infoDescription, infoCreationDate
/// ReplicaSearchItem: { displayName } -> fileNameTitle, which will be used as a backup as needed
class ReplicaSearchItem {
  ReplicaSearchItem(
    this.fileNameTitle,
    this.primaryMimeType,
    this.humanizedLastModified,
    this.humanizedFileSize,
    this.replicaLink,
    this.metaDescription,
    this.metaTitle,
  );

  String? primaryMimeType;
  String humanizedLastModified;
  String humanizedFileSize;
  late ReplicaLink replicaLink;
  late String fileNameTitle;
  late String metaDescription;
  late String metaTitle;

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
        // using the fileNameTitle notation to be consistent with desktop
        final fileNameTitle = link.displayName ?? result['displayName'];
        final metadata = result['metadata'];
        final metaDescription = metadata['description'] ?? '';
        final metaTitle = metadata['title'] ?? '';
        items.add(
          ReplicaSearchItem(
            fileNameTitle,
            primaryMimeType,
            humanizedLastModified,
            humanizedFileSize,
            link,
            metaDescription,
            metaTitle,
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
