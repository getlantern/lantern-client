import 'dart:io';
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
        fields: {'title': 'fileTitle'}, // Additional metadata
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
