import 'package:background_downloader/background_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/messaging/notifications.dart';

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

  void init() {
    // Listen for updates
    FileDownloader().updates.listen((update) async {
      if (update is TaskProgressUpdate && update.task is UploadTask) {
        await notifications.flutterLocalNotificationsPlugin.show(
          update.task.taskId.hashCode,
          'uploader'.i18n,
          'upload_in_progress'.i18n,
          notifications.getUploadProgressChannel(update.progress.toInt()),
        );
      } else if (update is TaskStatusUpdate && update.task is UploadTask) {
        final task = update.task as UploadTask;

        notifications.flutterLocalNotificationsPlugin
            .cancel(task.taskId.hashCode);

        var title = 'upload_complete'.i18n;
        if (update.status == TaskStatus.failed) {
          title = 'upload_failed'.i18n;
        } else if (update.status == TaskStatus.canceled) {
          title = 'upload_cancelled'.i18n;
        }

        // Show completion notification
        await notifications.flutterLocalNotificationsPlugin.show(
          task.taskId.hashCode,
          'uploader'.i18n,
          title,
          notifications.getUploadCompleteChannel(update.status),
          payload: Payload(
            type: PayloadType.Upload,
            data: task.metaData,
          ).toJson(),
        );

        // Remove completed task from queue
        FileDownloader().cancelTaskWithId(task.taskId);
      }
    });
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

    // Enqueue the upload task
    final task = UploadTask(
        url: uploadUrl,
        filename: fileName,
        fields: {'title': fileTitle}, // Additional metadata
        fileField: file.path,
        updates:
            Updates.statusAndProgress // request status and progress updates
        );

    FileDownloader().enqueue(task);

    sessionModel.trackUserAction(
        'User uploaded Replica content', uploadUrl, fileTitle);
  }

  /// Queries uploaded file information
  Future<void> queryFile({required String infohash}) async {
    final fetchEndpoint = '';
    final resp = await http.get(Uri.parse(fetchEndpoint));
    logger.v(resp);
  }
}
