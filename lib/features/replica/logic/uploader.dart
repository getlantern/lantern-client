import 'package:background_downloader/background_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/messaging/notifications.dart';

const uploadGroup = 'upload_group';

class ReplicaUploader {
  ReplicaUploader._private() {
    _init();
  }

  factory ReplicaUploader() {
    return _instance;
  }

  // Singleton instance
  static final ReplicaUploader _instance = ReplicaUploader._private();

  void _init() {
    FileDownloader().registerCallbacks(
      group: uploadGroup,
      taskStatusCallback: (update) async {
        if (update.task is UploadTask) {
          final task = update.task as UploadTask;

          // Remove progress notification
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
              data: update.responseBody,
            ).toJson(),
          );

          // Remove completed task from queue
          FileDownloader().cancelTaskWithId(task.taskId);
        }
      },
      taskProgressCallback: (update) async {
        if (update.task is UploadTask) {
          await notifications.flutterLocalNotificationsPlugin.show(
            update.task.taskId.hashCode,
            'uploader'.i18n,
            'upload_in_progress'.i18n,
            notifications.getUploadProgressChannel(update.progress.toInt()),
          );
        }
      },
    );
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
    await FileDownloader().enqueue(task);

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
