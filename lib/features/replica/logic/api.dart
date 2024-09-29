import 'package:dio/dio.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';
import 'package:permission_handler/permission_handler.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// Metadata of a video: it should accept null values since sometimes a thumbnail
// request succeeds, but not a duration request, and vice versa
class Metadata {
  Metadata(this.duration, this.thumbnail);

  double? duration;
  Uint8List? thumbnail;
}

class ReplicaApi {
  // cache duration upfront
  ReplicaApi(this.replicaHostAddr) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://$replicaHostAddr/replica/',
        connectTimeout: Duration(seconds: 30), // 30s
      ),
    );
    durationCache = LRUCache<ReplicaLink, double?>(100, doFetchDuration);
  }

  late Dio dio;
  final String replicaHostAddr;
  final defaultTimeoutDuration = const Duration(seconds: 7);
  late final LRUCache<ReplicaLink, double?> durationCache;

  bool get available {
    return replicaHostAddr != '';
  }

  Future<List<ReplicaSearchItem>> search(
    String query,
    SearchCategory category,
    int page,
    String lang,
  ) async {
    logger.v('ReplicaApi.search()');
    var s = '';
    switch (category) {
      case SearchCategory.Video:
      case SearchCategory.Audio:
      case SearchCategory.Image:
      case SearchCategory.Document:
      case SearchCategory.App:
        s = 'search?s=$query&offset=$page&orderBy=relevance&lang=$lang&type=${category.mimeTypes()}';
        break;
      case SearchCategory.News:
        s = 'search/news?s=$query&offset=$page&lang=$lang';
        break;
      case SearchCategory.Unknown:
        logger.e('Unknown category. Should never be triggered');
        break;
    }
    logger.v('_search(): uri: ${Uri.parse(s)}');
    final resp = await dio.get(s);
    if (resp.statusCode == 200) {
      logger
          .v('Statuscode: ${resp.statusCode} || body: ${resp.data.toString()}');
      sessionModel.trackUserAction(
          'User searched for Replica content', s, 'search');
      return ReplicaSearchItem.fromJson(category, resp.data);
    } else {
      logger.e(
        'Statuscode: ${resp.statusCode} || body: ${resp.data.toString()}',
      );
      throw Exception(
        'Statuscode: ${resp.statusCode} || body: ${resp.data.toString()}',
      );
    }
  }

  String getThumbnailAddr(ReplicaLink replicaLink) {
    return 'http://$replicaHostAddr/replica/thumbnail?replicaLink=${replicaLink.toMagnetLink()}';
  }

  String getDownloadAddr(ReplicaLink replicaLink) {
    return 'http://$replicaHostAddr/replica/download?link=${replicaLink.toMagnetLink()}';
  }

  Future<Uint8List> getImageBytesFromURL(String imageURL) async {
    return (await NetworkAssetBundle(Uri.parse(imageURL)).load(imageURL))
        .buffer
        .asUint8List();
  }

  String getViewAddr(ReplicaLink replicaLink) {
    return 'http://$replicaHostAddr/replica/view?link=${replicaLink.toMagnetLink()}';
  }

  Future<SearchCategory> fetchCategoryFromReplicaLink(
    ReplicaLink replicaLink,
  ) async {
    var u = 'download?link=${replicaLink.toMagnetLink()}';
    logger.v('fetchCategoryFromReplicaLink: $u');

    try {
      var resp = await dio.head(u).timeout(defaultTimeoutDuration);
      if (resp.statusCode != 200) {
        logger.e('error fetching category from $u');
      }
      return SearchCategoryFromMimeType(resp.headers.value('content-type'));
    } on TimeoutException catch (_) {
      // On a timeout, just return an unknown category
      logger.w(
        'Timed out while fetching category from replica link, will return Unknown',
      );
      return SearchCategory.Unknown;
    }
  }

  /// fetchDuration fetches the duration of 'replicaLink' through Replica's backend.
  /// If it can't find it (or failed to find it), return a null
  ValueListenable<CachedValue<double?>> getDuration(ReplicaLink replicaLink) {
    return durationCache.get(replicaLink);
  }

  Future<double?> doFetchDuration(ReplicaLink replicaLink) async {
    var s = 'duration?replicaLink=${replicaLink.toMagnetLink()}';
    // logger.v('Duration request uri: $s');
    double? duration;

    try {
      final durationResp = await dio.get(s);
      if (durationResp.statusCode != 200) {
        logger.e(
          'fetch duration: ${durationResp.statusCode} -> ${durationResp.data.toString()}',
        );
      }
      // logger.v('Duration request success: $duration');
      duration = durationResp.data != ''
          ? double.parse(durationResp.data.toString())
          : null;
      logger.v(duration);
    } catch (err) {
      if (err is DioException) {
        logger.e(
          'Dio Error - failed to fetch duration. Error: ${err.error}',
        );
      } else {
        logger.e('Unknown error - failed to fetch duration. Error: $err');
      }
    }
    return duration;
  }

  Future<void> download(ReplicaLink link) async {
    logger.v('Download()');
    var hasPermission = await Permission.storage.request().isGranted;
    if (!hasPermission) {
      logger.w('Failed to get read/write storage permission');
      return null;
    }
    logger.v('Permission granted');

    // The download endpoint doesn't return an HTTP response until it's actually
    // completely downloaded the file from Replica. When used with the download
    // manager, this causes the system notification to only show up once the
    // file is downloaded, defeating the purpose of a progress bar.
    // So instead, we use the view endpoint which starts streaming the data to
    // the client immediately.
    final u = getViewAddr(link);
    final displayName = link.displayName ?? link.infohash;
    await replicaModel.downloadFile(u, displayName);
  }

  Future<void> fetch(ReplicaLink link, String localFilePath) async {
    final resp = await dio.download(
      getViewAddr(link),
      localFilePath,
      deleteOnError: true,
    );
    if (resp.statusCode != 200) {
      logger.e(
        'Failed to fetch: ${resp.statusCode} -> ${resp.data.toString()}',
      );
    }
  }

  /// Hits the /object_info endpoint to get title, description and creationDate strings
  /// Returns an object with '' fields for all 3 if not found
  /// We only call this from inside the Replica Viewer components, since we use the title and description returned as part oft he ReplicaSearchItem for the list views
  Future<ReplicaObjectInfo> fetchObjectInfo(
    ReplicaLink replicaLink,
  ) async {
    var obj = 'object_info?replicaLink=${replicaLink.toMagnetLink()}';
    logger.v('fetch object_info: $obj');

    try {
      var resp = await dio.get(obj).timeout(defaultTimeoutDuration);
      if (resp.statusCode != 200) {
        logger.e('error fetching object_info $obj');
        return EmptyReplicaObjectInfo();
      }
      final infoDescription = resp.data['description'];
      final infoTitle = resp.data['title'];
      final infoCreationDate = resp.data['creationDate'];
      return ReplicaObjectInfo(
        infoDescription ?? '',
        infoTitle ?? '',
        infoCreationDate ?? '',
      );
    } on TimeoutException catch (_) {
      logger.w(
        'Timed out while fetching object_info from replica link, will return',
      );
      return EmptyReplicaObjectInfo();
    } catch (err) {
      logger.e('Error while fetching object_info $err');
      return EmptyReplicaObjectInfo();
    }
  }
}
