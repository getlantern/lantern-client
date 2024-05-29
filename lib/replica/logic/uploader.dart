import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/notifications.dart';

/// ReplicaUploader is a singleton class. Use it like this:
/// - Initialize ReplicaUploader by calling ReplicaUploader.inst.init()
///   - Ideally in an initState() of a top-level widget
///   - Calling it multiple times is safe
/// - Upload files with ReplicaUploader.inst.uploadFile()
///     to schedule a background upload
///
/// There are two notifications here:
/// - One (Flutter side) to track the upload's progress, handled in review.dart
/// - One (native) when the upload is done.
///   - If it succeeded (i.e., not failed or got cancelled), a native notification shows up
///   - ** NOT YET IMPLEMENTED ** the user can click it and be prompted with a Share dialog to share the Replica link
class ReplicaUploader {
  // Private, named constructor to avoid instantiations
  ReplicaUploader._private();

  // Singleton instance to access the class
  static final ReplicaUploader inst = ReplicaUploader._private();
  FlutterUploader? uploader;

  void init() {
    if (inst.uploader != null) {
      // Already initialized
      return;
    }
    inst.uploader = FlutterUploader();
    ReplicaUploader.inst.uploader!
        .setBackgroundHandler(ReplicaUploaderBackgroundHandler);
  }

  /// fileTitle: no extension
  /// fileName: has extension
  Future<void> uploadFile({
    required File file,
    required String fileName,
    String? fileDescription,
    required String fileTitle,
  }) async {
    final replicaAddr = await sessionModel.getReplicaAddr();
    var uploadUrl =
        'http://$replicaAddr/replica/upload?name=${Uri.encodeComponent(fileName)}';
    // add description
    if (fileDescription != null) {
      uploadUrl += '&description=${Uri.encodeComponent(fileDescription)}';
    }
    // add title
    if (fileTitle.isNotEmpty) {
      uploadUrl += '&title=${Uri.encodeComponent(fileTitle)}';
    }
    logger.v('uploadUrl: $uploadUrl');
    await inst.uploader!.enqueue(
      RawUpload(
        url: uploadUrl,
        path: file.path,
        method: UploadMethod.POST,
      ),
    );
    sessionModel.trackUserAction(
        'User uploaded Replica content', uploadUrl, fileTitle);
  }

  // TODO <08-10-22, kalli> Figure out how to query endpoint with infohash (for rendering preview after uploading a file)
  Future<void> queryFile({
    required String infohash,
  }) async {
    final fetchEndpoint = '';
    final resp = await http.get(Uri.parse(fetchEndpoint));
    logger.v(resp);
  }
}

void ReplicaUploaderBackgroundHandler() async {
  WidgetsFlutterBinding.ensureInitialized();
  var isolateUploader = FlutterUploader();

  // Listen to progress and show a single notification showing the progress

  // TODO <08-10-22, kalli> Upload notifications pattern will be updated in subsequent ticket
  isolateUploader.progress.listen((progress) async {
    // This code runs in a different Flutter engine than the usual UI code, so
    // we have to make sure localizations are initialized here before
    // continuing.
    await Localization.ensureInitialized();
    await notifications.flutterLocalNotificationsPlugin
        .show(
      progress.taskId.hashCode,
      'uploader'.i18n,
      'upload_in_progress'.i18n,
      notifications.getUploadProgressChannel(progress.progress ?? 0),
    )
        .catchError((e, stack) {
      logger.e('Error while showing notification: $e, $stack');
    });
  });

  isolateUploader.result.listen((result) async {
    await Localization.ensureInitialized();
    // logger.v(
    //     'result callback for ${result.taskId}: ${result.status?.description}');

    // Ignore all other states
    if (result.status != UploadTaskStatus.complete &&
        result.status != UploadTaskStatus.canceled &&
        result.status != UploadTaskStatus.failed) {
      return;
    }

    // Delete the progress notification
    // ignore: unawaited_futures
    notifications.flutterLocalNotificationsPlugin
        .cancel(result.taskId.hashCode);

    // Show a notification for completed, failed or canceled notifications
    var title = 'upload_complete'.i18n;
    if (result.status == UploadTaskStatus.failed) {
      title = 'upload_failed'.i18n;
    } else if (result.status == UploadTaskStatus.canceled) {
      title = 'upload_cancelled'.i18n;
    }
    // ignore: unawaited_futures
    notifications.flutterLocalNotificationsPlugin
        .show(
      result.taskId.hashCode,
      'uploader'.i18n,
      title,
      notifications.getUploadCompleteChannel(result),
      payload:
          Payload(type: PayloadType.Upload, data: result.response).toJson(),
    )
        .catchError((e, stack) {
      logger.e('Error while showing notification: $e, $stack');
    });

    // Clear all uploads in the uploader's record
    // ignore: unawaited_futures
    isolateUploader.clearUploads();
  });
}
