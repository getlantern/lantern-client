import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/messaging/notifications.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    inst.uploader = FlutterUploader();
    ReplicaUploader.inst.uploader!
        .setBackgroundHandler(ReplicaUploaderBackgroundHandler);

    // XXX <19-12-2021> soltzen: It's not possible to access localized strings
    // using the 'i18n_extension' extension we're currently using inside
    // `ReplicaUploaderBackgroundHandler()` since it's running in an isolate
    // different than the main program's isolate.
    //
    // It is also not possible to save the localized strings as a global/static
    // variable and access it later there.
    //
    // An easy way to mitigate this is to save the localized strings somewhere
    // in persistent storage (i.e., SharedPreferences) and then retrieve it
    // later in the isolate.
    //
    // A better approach is to use a plugin that doesn't require a context
    // (i.e., easy_localization:
    // https://github.com/aissat/easy_localization/issues/210), but the overhead
    // of this approach is really minimal: only downside I see is if we choose
    // to change the localization for the upload notifications in the future.
    // We'll first need to nuke the existing device's SharedPrefs to do that.
    SharedPreferences.getInstance().then((prefs) async {
      if (!prefs.containsKey('upload_complete')) {
        await prefs.setString('upload_complete', 'upload_complete'.i18n);
      }
      if (!prefs.containsKey('upload_in_progress')) {
        await prefs.setString('upload_in_progress', 'upload_in_progress'.i18n);
      }
      if (!prefs.containsKey('uploader')) {
        await prefs.setString('uploader', 'uploader'.i18n);
      }
      if (!prefs.containsKey('upload_failed')) {
        await prefs.setString('upload_failed', 'upload_failed'.i18n);
      }
      if (!prefs.containsKey('upload_cancelled')) {
        await prefs.setString('upload_cancelled', 'upload_cancelled'.i18n);
      }
    });
  }

  Future<void> uploadFile(File file, String displayName) async {
    var uploadUrl =
        'http://${ReplicaCommon.getReplicaServerAddr()!}/replica/upload?name=${Uri.encodeComponent(displayName)}';
    logger.v('uploadUrl: $uploadUrl');
    await inst.uploader!.enqueue(RawUpload(
      url: uploadUrl,
      path: file.path,
      method: UploadMethod.POST,
    ));
  }
}

void ReplicaUploaderBackgroundHandler() async {
  WidgetsFlutterBinding.ensureInitialized();
  var isolateUploader = FlutterUploader();

  // Fetch localized strings. If not possible, default to hard-coded English
  // localization
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 3));
  } on Exception catch (_) {
    logger.w('Failed to fetch shared prefs: will go on without it');
  }
  var uploadCompleteStr =
      prefs?.getString('upload_complete') ?? 'Upload Complete';
  var uploadInProgressStr =
      prefs?.getString('upload_in_progress') ?? 'Upload in Progress';
  var uploaderStr = prefs?.getString('uploader') ?? 'Uploader';
  var uploadFailedStr = prefs?.getString('upload_failed') ?? 'Upload Failed';
  var uploadCancelledStr =
      prefs?.getString('upload_cancelled') ?? 'Upload Cancelled';

  // Listen to progress and show a single notification showing the progress
  isolateUploader.progress.listen((progress) {
    notifications.flutterLocalNotificationsPlugin
        .show(progress.taskId.hashCode, uploaderStr, uploadInProgressStr,
            notifications.getUploadProgressChannel(progress.progress ?? 0))
        .catchError((e, stack) {
      logger.e('Error while showing notification: $e, $stack');
    });
  });

  isolateUploader.result.listen((result) async {
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
    var title = uploadCompleteStr;
    if (result.status == UploadTaskStatus.failed) {
      title = uploadFailedStr;
    } else if (result.status == UploadTaskStatus.canceled) {
      title = uploadCancelledStr;
    }
    // ignore: unawaited_futures
    notifications.flutterLocalNotificationsPlugin
        .show(result.taskId.hashCode, uploaderStr, title,
            notifications.getUploadCompleteChannel(result),
            payload: Payload(type: PayloadType.Upload, data: result.response)
                .toJson())
        .catchError((e, stack) {
      logger.e('Error while showing notification: $e, $stack');
    });

    // Clear all uploads in the uploader's record
    // ignore: unawaited_futures
    isolateUploader.clearUploads();
  });
}
