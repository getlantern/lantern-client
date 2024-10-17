import 'package:filesize/filesize.dart';
import 'package:lantern/common/ui/humanize_seconds.dart';
import 'package:lantern/features/replica/common.dart';

/// Defines the generic structure of a Replica search result
/// The server returns a { metadata: {title}, {description}} field in its response. It's a bit redundant since we can get that same info (+ the creationDate field) via the `/object_info` endpoint. We are rendering the title and description returned as part of ReplicaSearchItem in the Results views and requesting the same info again from the `/object_info` endpoint when we are viewing a specific replicaLink in one of the Viewers.
/// There is also a {displayName} field returned in the ReplicaSearchItem, which corresponds to the file name at the moment of its upload.
/// We will be using the following notation to disambiguate:
/// ReplicaSearchItem: {metadata: {title}, {description}} -> metaTitle, metaDescription
/// Viewer: {title, description, creationDate} returned from `/object_info` -> infoTitle, infoDescription, infoCreationDate
/// ReplicaSearchItem: { displayName } -> fileNameTitle, which will be used as a backup as needed
///
/// Serp api results have now been added to Replica Search API. Unfortunately, these have a slightly different schema so
/// I've had to make this class a bit of a chameleon :(. However this does mirror how the desktop is setup with web and news
/// results combined with replica results. I think we should standardize this API a bit so all results follow a similar schema.
/// For now, when on a serp tab (news or web) the ser<property> should be used.
class ReplicaSearchItem {
  ReplicaSearchItem(
    this.fileNameTitle,
    this.primaryMimeType,
    this.humanizedLastModified,
    this.humanizedFileSize,
    this.replicaLink,
    this.metaDescription,
    this.metaTitle,
    this.serpTitle,
    this.serpSnippet,
    this.serpSource,
    this.serpDate,
    this.serpLink,
  );

  String? primaryMimeType;
  String humanizedLastModified;
  String humanizedFileSize;
  late ReplicaLink replicaLink;
  late String fileNameTitle;
  late String metaDescription;
  late String metaTitle;
  late String? serpTitle;
  late String? serpSnippet;
  late String? serpSource;
  late String? serpDate;
  late String? serpLink;

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
        var link;
        if (category == SearchCategory.News) {
          // serp results do not have a replica link yet (maybe in future?),
          // however it's a hard requirement by the ReplicaSearchItem type
          // making it optional is not a good idea given the other screens reliance
          // on it always existing and given serp results may have magnet links in the future
          // I don't think a refactor is worth it. Therefore, for now, I am simply creating a dumb one:
          link = ReplicaLink.New(
            'magnet%3A%3Fxt%3Durn%3Abtih%3Ae3cc2486d0875a07b82df20de98db7fab5e6371e%26xs',
          );
        } else {
          link = ReplicaLink.New(result['replicaLink'] as String);
        }
        // Can't continue if replicaLink is not there
        if (link == null) {
          logger.e('Bad replicaLink: ${result['replicaLink'] as String}');
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

        // displayName, lastModified and fileSize are always there on non-serp results
        final humanizedLastModified = category != SearchCategory.News
            ? DateTime.now()
                .difference(DateTime.parse(result['lastModified'] as String))
                .inSeconds
                .humanizeSeconds()
            : '';
        final humanizedFileSize = result['fileSize'] != null
            ? filesize(result['fileSize'] as int)
            : '';
        // using the fileNameTitle notation to be consistent with desktop
        final fileNameTitle = link.displayName ?? result['displayName'] ?? '';
        final metadata = result['metadata'];
        final metaDescription =
            metadata != null ? metadata['description'] ?? '' : '';
        final metaTitle = metadata != null ? metadata['title'] ?? '' : '';

        // serp
        final serpTitle = result['title'];
        final serpSnippet = result['snippet'];
        final serpSource = result['source'];
        final serpDate = result['date'];
        final serpLink = result['link'];

        items.add(
          ReplicaSearchItem(
            fileNameTitle,
            primaryMimeType,
            humanizedLastModified,
            humanizedFileSize,
            link,
            metaDescription,
            metaTitle,
            serpTitle,
            serpSnippet,
            serpSource,
            serpDate,
            serpLink,
          ),
        );
      } catch (err) {
        logger.e(
          'Error parsing item ${result['replicaLink'] ??= '[invalid link]'}. Will ignore link',
        );
        continue;
      }
    }
    return items;
  }
}
