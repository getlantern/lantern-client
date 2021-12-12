import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:lantern/messaging/notifications.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common.dart';

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
  ReplicaApi(this.replicaHostAddr) {
    dio = Dio(BaseOptions(
      baseUrl: 'http://$replicaHostAddr/replica/',
      connectTimeout: 10000, // 10s
    ));
  }

  late Dio dio;
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

  Future<List<ReplicaSearchItem>> search(
      String query, SearchCategory category, int page, String lang) async {
    logger.v('XXX ReplicaApi.search()');
    var s = '';
    switch (category) {
      case SearchCategory.Video:
      case SearchCategory.Audio:
      case SearchCategory.Image:
      case SearchCategory.Document:
      case SearchCategory.App:
        s = 'search?s=$query&offset=$page&orderBy=relevance&lang=$lang&type=${category.mimeTypes()}';
        break;
      case SearchCategory.Unknown:
        throw Exception('Unknown category. Should never be triggered');
    }
    logger.v('XXX _search(): uri: ${Uri.parse(s)}');

    final resp = await dio.get(s);
    if (resp.statusCode == 200) {
      logger.v('XXX Statuscode: ${resp.statusCode}');
      logger.v('XXX body: ${resp.data.toString()}');
      return ReplicaSearchItem.fromJson(category, resp.data);
    } else {
      throw Exception(
          'Failed to fetch search query: ${resp.statusCode} -> ${resp.data.toString()}');
    }
  }

  String getThumbnailAddr(ReplicaLink replicaLink) {
    return 'http://$replicaHostAddr/replica/thumbnail?replicaLink=${replicaLink.toMagnetLink()}';
  }

  String getDownloadAddr(ReplicaLink replicaLink) {
    return 'http://$replicaHostAddr/replica/download?link=${replicaLink.toMagnetLink()}';
  }

  String getViewAddr(ReplicaLink replicaLink) {
    return 'http://$replicaHostAddr/replica/view?link=${replicaLink.toMagnetLink()}';
  }

  Future<SearchCategory> fetchCategoryFromReplicaLink(
      ReplicaLink replicaLink) async {
    var u = 'download?link=${replicaLink.toMagnetLink()}';
    logger.v('XXX fetchCategoryFromReplicaLink: $u');

    try {
      var resp = await dio.head(u).timeout(_defaultTimeoutDuration);
      if (resp.statusCode != 200) {
        throw Exception('fetching category from $u');
      }
      return SearchCategoryFromContentType(resp.headers.value('content-type'));
    } on TimeoutException catch (_) {
      // On a timeout, just return an unknown category
      return SearchCategory.Unknown;
    }
  }

  // overrideHostAddr is used mainly for testing and overriding a specific
  // usage of host addr
  Future<double> fetchDuration(ReplicaLink replicaLink) async {
    var s = 'duration?replicaLink=${replicaLink.toMagnetLink()}';
    logger.v('XXX Duration request uri: $s');
    final durationResp = await dio.get(s);
    if (durationResp.statusCode != 200) {
      throw Exception(
          'fetch duration: ${durationResp.statusCode} -> ${durationResp.data.toString()}');
    }
    var duration = 0.0;
    try {
      duration = double.parse(durationResp.data.toString());
    } catch (err) {
      throw Exception(
          'parse duration: ${durationResp.statusCode} -> ${durationResp.data.toString()}');
    }
    logger.v('XXX Duration request success: $duration');
    return duration;
  }

  Future<void> download(ReplicaLink link) async {
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
    final displayName = link.displayName ?? link.infohash;
    await replicaModel.downloadFile(u, displayName);
  }
}
