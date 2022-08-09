import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/notifications.dart';

/// ReplicaUploader is a singleton class. Use it like this:
/// - Initialize ReplicaUploader by calling ReplicaUploader.inst.init()
///   - Ideally in an initState() of a top-level widget
///   - Calling it multiple times is safe
/// - Upload files with ReplicaUploader.inst.uploadFile()
///   - This'll use flutter_uploader plugin, which uses Android's WorkManager, to
///     schedule a background upload
///
/// There are two notifications here:
/// - One to track the upload's progress
/// - One when the upload is done.
///   - If it succeeded (i.e., not failed or got cancelled), the user can click
///     on this notification, they would be prompted with a Share dialog to share
///     the Replica link
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

  Future<void> uploadFile(File file, String displayName) async {
    final replicaAddr = await sessionModel.getReplicaAddr();
    // TODO <08-09-22, kalli> Depends on naming decisions
    var uploadUrl =
        'http://$replicaAddr/replica/upload?name=${Uri.encodeComponent(displayName)}';
    logger.v('uploadUrl: $uploadUrl');
    await inst.uploader!.enqueue(
      RawUpload(
        url: uploadUrl,
        path: file.path,
        method: UploadMethod.POST,
      ),
    );
  }
}

void ReplicaUploaderBackgroundHandler() async {
  WidgetsFlutterBinding.ensureInitialized();
  var isolateUploader = FlutterUploader();

  // Listen to progress and show a single notification showing the progress
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
