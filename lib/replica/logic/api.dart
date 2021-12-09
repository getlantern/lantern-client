import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/searchcategory.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// Metadata of a video: it should accept null values since sometimes a
// thumbnail request succeeds, but not a duration request, and vice versa
class Metadata {
  Metadata(this.duration, this.thumbnail);
  double? duration;
  Uint8List? thumbnail;
}

class ReplicaApi {
  ReplicaApi(this.replicaHostAddr);
  final String replicaHostAddr;
  final _defaultTimeoutDuration = const Duration(seconds: 7);
  final notifications = Notifications((payloadString) {
    if (payloadString?.isEmpty == true) {
      return;
    }
    var payload = Payload.fromJson(payloadString!);
    if (payload.type != PayloadType.download) {
      return;
    }
    OpenFile.open(payload.data);
  });
  final Dio dio = Dio();

  Future<List<ReplicaSearchItem>> search(
      String query, SearchCategory category, int page, String lang) async {
    logger.v('XXX ReplicaApi.search()');
    var s = '';
    switch (category) {
      case SearchCategory.Web:
        s = 'http://$replicaHostAddr/replica/search/serp_web?s=$query&offset=$page&lang=$lang';
        break;
      case SearchCategory.Video:
      case SearchCategory.Audio:
      case SearchCategory.Image:
      case SearchCategory.Document:
      case SearchCategory.App:
        s = 'http://$replicaHostAddr/replica/search?s=$query&offset=$page&orderBy=relevance&lang=$lang&type=${category.mimeTypes()}';
        break;
      case SearchCategory.Unknown:
        throw Exception('Unknown category. Should never be triggered');
    }
    logger.v('XXX _search(): uri: ${Uri.parse(s)}');
    final resp = await http.get(Uri.parse(s));
    if (resp.statusCode == 200) {
      logger.v('XXX Statuscode: ${resp.statusCode}');
      // logger.v('body: ${resp.body}');
      return ReplicaSearchItem.fromJson(category, resp.body);
    } else {
      throw Exception(
          'Failed to fetch search query: ${resp.statusCode} -> ${resp.body}');
    }
  }

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

  // overrideHostAddr is used mainly for testing and overriding a specific
  // usage of host addr
  Future<Uint8List> fetchThumbnail(ReplicaLink replicaLink,
      {String? overrideHostAddr}) async {
    var hostAddr = overrideHostAddr ?? replicaHostAddr;
    var uri = Uri.parse(
        'http://$hostAddr/replica/thumbnail?replicaLink=${replicaLink.toMagnetLink()}');
    logger.v('XXX Thumbnail request uri: $uri');
    final thumbnailResp = await http.get(uri);
    if (thumbnailResp.statusCode != 200) {
      throw Exception(
          'fetch search query: ${thumbnailResp.statusCode} -> ${thumbnailResp.body}');
    }
    final thumbnail = thumbnailResp.bodyBytes;
    logger.v('XXX Thumbnail request success: ${thumbnail.length}');
    return thumbnail;
  }

  // overrideHostAddr is used mainly for testing and overriding a specific
  // usage of host addr
  Future<double> fetchDuration(ReplicaLink replicaLink,
      {String? overrideHostAddr}) async {
    var hostAddr = overrideHostAddr ?? replicaHostAddr;
    var uri = Uri.parse(
        'http://$hostAddr/replica/duration?replicaLink=${replicaLink.toMagnetLink()}');
    logger.v('XXX Duration request uri: $uri');
    final durationResp = await http.get(uri);
    if (durationResp.statusCode != 200) {
      throw Exception(
          'fetch duration: ${durationResp.statusCode} -> ${durationResp.body}');
    }
    var duration = 0.0;
    try {
      duration = double.parse(durationResp.body);
    } catch (err) {
      throw Exception(
          'parse duration: ${durationResp.statusCode} -> ${durationResp.body}');
    }
    logger.v('XXX Duration request success: $duration');
    return duration;
  }

  Future<void> download(ReplicaLink link, String displayName) async {
    logger.v('Download()');
    var hasPermission = await Permission.storage.request().isGranted;
    if (!hasPermission) {
      throw Exception('Permission');
    }
    logger.v('Permission granted');
    // The download endpoint doesn't return an HTTP response until it's actually
    // completely downloaded the file from Replica. When used with the download
    // manager, this causes the system notification to only show up once the
    // file is downloaded, defeating the purpose of a progress bar.
    // So instead, we use the view endpoint which starts streaming the data to
    // the client immediately.
    final u = getViewAddr(link);
    await replicaModel.downloadFile(u, displayName);
  }

  // Future<void> download(ReplicaLink replicaLink, String displayName) async {
  //   logger.v('XXX downloading ${replicaLink.infohash}');
  //   var hasPermission = await Permission.storage.request().isGranted;
  //   if (!hasPermission) {
  //     throw Exception('Permission');
  //   }
  //   logger.v('Permission granted');
  //   final dir = await getExternalStorageDirectory();
  //   if (dir == null) {
  //     throw Exception('downloads directory');
  //   }
  //   logger.v('dir.path: ${dir.path}');

  //   await FlutterDownloader.enqueue(
  //     url: getDownloadAddr(replicaLink),
  //     savedDir: dir.path,
  //     fileName: displayName,
  //     showNotification: true,
  //     openFileFromNotification: true,
  //     saveInPublicStorage: true,
  //   );
  // }
}
