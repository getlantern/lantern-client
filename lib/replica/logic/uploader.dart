import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:lantern/messaging/notifications.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

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
    logger.v('Initialized ReplicaUploader');
    inst.uploader = FlutterUploader();
    ReplicaUploader.inst.uploader!
        .setBackgroundHandler(ReplicaUploaderBackgroundHandler);
  }

  Future<void> uploadFile(File file) async {
    var uploadUrl =
        'http://${ReplicaCommon.getReplicaServerAddr()!}/replica/upload?name=${Uri.encodeComponent(basename(file.path))}';
    logger.v('uploadUrl: $uploadUrl');
    await inst.uploader!.enqueue(RawUpload(
      url: uploadUrl,
      path: file.path,
      method: UploadMethod.POST,
    ));
  }
}

void ReplicaUploaderBackgroundHandler() {
  WidgetsFlutterBinding.ensureInitialized();
  var isolateUploader = FlutterUploader();

  // Listen to progress and show a single notification showing the progress
  isolateUploader.progress.listen((progress) {
    notifications.flutterLocalNotificationsPlugin
        .show(progress.taskId.hashCode, 'Uploader', 'Upload in Progress',
            notifications.getUploadProgressChannel(progress.progress ?? 0))
        .catchError((e, stack) {
      logger.e('Error while showing notification: $e, $stack');
    });
  });

  isolateUploader.result.listen((result) {
    // logger.v(
    //     'result callback for ${result.taskId}: ${result.status?.description}');

    // Ignore all other states
    if (result.status != UploadTaskStatus.complete &&
        result.status != UploadTaskStatus.canceled &&
        result.status != UploadTaskStatus.failed) {
      return;
    }

    // Delete the progress notification
    notifications.flutterLocalNotificationsPlugin
        .cancel(result.taskId.hashCode);

    // Show a notification for completed, failed or canceled notifications
    var title = 'Upload Complete';
    if (result.status == UploadTaskStatus.failed) {
      title = 'Upload Failed';
    } else if (result.status == UploadTaskStatus.canceled) {
      title = 'Upload Canceled';
    }
    notifications.flutterLocalNotificationsPlugin
        .show(result.taskId.hashCode, 'Uploader', title,
            notifications.getUploadCompleteChannel(result),
            payload: Payload(type: PayloadType.Upload, data: result.response)
                .toJson())
        .catchError((e, stack) {
      logger.e('Error while showing notification: $e, $stack');
    });

    // Clear all uploads in the uploader's record
    isolateUploader.clearUploads();
  });
}
