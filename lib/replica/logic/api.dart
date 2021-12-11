import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:lantern/messaging/notifications.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/vpn/vpn.dart';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
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
  ReplicaApi(this.replicaHostAddr) {
    dio = Dio(BaseOptions(
      baseUrl: 'http://$replicaHostAddr/replica/',
      connectTimeout: 10000, // 10s
    ));
  }
  late Dio dio;
  final _downloaderCallbackPort = ReceivePort();
  static final _downloadeManagerIsolateName = 'downloader_send_port';
  // This will be initialized from bindDownloaderBackgroundIsolate()
  late Function() _onDownloadError;
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

  Future<String?> _prepAndFetchDownloadsDir() async {
    var hasPermission = await Permission.storage.request().isGranted;
    if (!hasPermission) {
      logger.w('Failed to get read/write storage permission');
      return null;
    }

    try {
      return await AndroidPathProvider.downloadsPath;
    } catch (e) {
      final d = await getExternalStorageDirectory();
      return d?.path;
    }
  }

  Future<void> download(ReplicaLink link) async {
    final downloadsDir = await _prepAndFetchDownloadsDir();
    if (downloadsDir == null) {
      logger.e('Failed to fetch downloads dir');
      _onDownloadError();
      return;
    }
    logger.v('downloadsDir: $downloadsDir');

    final u = getDownloadAddr(link);
    logger.v('XXX downloadAddr: $u');
    var displayName = link.displayName ?? link.infohash;
    var taskId = await FlutterDownloader.enqueue(
      url: u,
      savedDir: downloadsDir,
      showNotification: true,
      fileName: displayName,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );
    logger.v('XXX taskId: $taskId');
  }

  void bindDownloaderBackgroundIsolate(
      Function() onDownloadError, Function()? onDownloadStarted) {
    _onDownloadError = onDownloadError;
    var isSuccess = IsolateNameServer.registerPortWithName(
        _downloaderCallbackPort.sendPort, _downloadeManagerIsolateName);
    if (!isSuccess) {
      // XXX <10-12-2021> soltzen: This is a rare case but best we handle it
      logger.w(
          'Failed to register a callback. Register an empty callback for FlutterDownloader so that downloads do not fail');
      FlutterDownloader.registerCallback(_emptyDownloaderCallback);
      return;
    }

    _downloaderCallbackPort.listen((dynamic data) {
      logger.v('XXX UI Isolate Callback: $data');
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];

      if (status == null) {
        return;
      }

      if (status == DownloadTaskStatus.failed) {
        onDownloadError();
      } else if (status == DownloadTaskStatus.enqueued &&
          onDownloadStarted != null) {
        onDownloadStarted();
      }
    });

    FlutterDownloader.registerCallback(_defaultDownloaderCallback);
  }

  void unbindDownloadManagerIsolate() {
    IsolateNameServer.removePortNameMapping(_downloadeManagerIsolateName);
  }
}

void _emptyDownloaderCallback(
    String id, DownloadTaskStatus status, int progress) {}

void _defaultDownloaderCallback(
    String id, DownloadTaskStatus status, int progress) {
  logger.v(
      'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  final send = IsolateNameServer.lookupPortByName(
      ReplicaApi._downloadeManagerIsolateName)!;
  send.send([id, status, progress]);
}
