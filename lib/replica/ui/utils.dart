import 'package:file_picker/file_picker.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:lantern/replica/common.dart';
import 'package:path/path.dart' as path;

// renderReplicaLongPressMenuItem is used for rendering list/grid items located
// in the ./ui/replica/list_item directory
SizedBox renderReplicaLongPressMenuItem(
  BuildContext context,
  ReplicaApi api,
  ReplicaLink link,
) {
  return SizedBox(
    height: 48,
    child: Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListItemFactory.focusMenuItem(
            icon: ImagePaths.file_download,
            content: 'download'.i18n,
            onTap: () async {
              await api.download(link);
              BotToast.showText(text: 'download_started'.i18n);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    ),
  );
}

// renderReplicaMediaViewScreen is used as the root widget for all Replica media
// views (located in ./ui/replica/viewers directory)
// TODO <08-08-22, kalli> This is a layout, rename and/or move accordingly
Widget renderReplicaMediaViewScreen({
  required BuildContext context,
  required ReplicaApi api,
  required ReplicaLink link,
  required SearchCategory category,
  required Widget body,
  required Color backgroundColor,
  Color? foregroundColor,
  String? mimeType,
}) {
  return BaseScreen(
    showAppBar: true,
    foregroundColor: foregroundColor,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CText(
          link.displayName ?? 'untitled'.i18n,
          style: tsHeading3.copiedWith(color: foregroundColor),
        ),
        if (mimeType != null)
          CText(
            mimeType,
            style: tsOverline.copiedWith(color: foregroundColor),
          )
        else
          CText(
            category.toShortString(),
            style: tsOverline.copiedWith(color: foregroundColor),
          )
      ],
    ),
    backgroundColor: backgroundColor,
    actions: [
      IconButton(
        onPressed: () async {
          await api.download(link);
          // TODO <08-08-22, kalli> Confirm we can use BotToast
          BotToast.showText(text: 'download_started'.i18n);
        },
        icon: CAssetImage(
          size: 20,
          path: ImagePaths.file_download,
          color: foregroundColor,
        ),
      ),
    ],
    body: body,
  );
}

// Upload journey goes like this:
// - Prompt user to pick a file
// - Show them the disclaimer
//   - Or not, if they asked not to be shown again (through a checkbox)
// - Start the upload
//   - Notify them through a notification
// - Track the upload's progress through a notification
// - When the upload is done, send another notification saying it's done
//   - If the user clicks on this notification, they would be prompted
//     with a Share dialog to share the Replica link
// TODO <08-08-22, kalli> Will be overhauled entirely, and will be broken up in multiple screens
// TODO <08-09-22, kalli> Make sure comments are updated
Future<void> onUploadButtonPressed(BuildContext context) async {
  var result = await FilePicker.platform.pickFiles();
  if (result == null) {
    // If user didn't pick a file, do nothing
    return;
  }
  var file = File(result.files.single.path!);
  logger.v('Picked a file $file');

  final suppressUploadWarning = await replicaModel.getSuppressUploadWarning();
  if (suppressUploadWarning == true) {
    // Immediately proceed to upload screen
    await context.pushRoute(
      ReplicaUploadTitle(
        fileToUpload: file,
      ),
    );
  } else {
    // Warn user about dangers of uploading first, then proceed to upload screen
    CDialog(
      title: 'replica_upload_confirmation_title'.i18n,
      description: 'replica_upload_confirmation_body'.i18n,
      checkboxLabel: 'dont_show_me_this_again'.i18n,
      agreeText: 'replica_upload_confirmation_agree'.i18n,
      maybeAgreeAction: (doNotShowAgain) async {
        if (doNotShowAgain == true) {
          await replicaModel.setSuppressUploadWarning(true);
        }
        await context.pushRoute(
          ReplicaUploadTitle(
            fileToUpload: file,
          ),
        );
        return true;
      },
    ).show(context);
  }
}

Future<Widget> getUploadThumbnailFromFile({
  required File file,
  required double width,
  required double height,
  int? maxWidth,
  int? maxHeight,
}) async {
  var cat = SearchCategoryFromMimeType(lookupMimeType(file.path));
  switch (cat) {
    case SearchCategory.Image:
      return Image.file(
        file,
        width: width,
        height: height,
        filterQuality: FilterQuality.medium,
        fit: BoxFit.cover,
      );
    case SearchCategory.Video:
      // We're using VideoPlayerController to get the duration of the video,
      // which we'll use to pick a thumbnail in the middle
      // TODO <08-08-22, kalli> Seems a bit hacky to me
      var c = VideoPlayerController.file(file);
      var duration = await c
          .initialize()
          .then((_) => c.value.duration.inMilliseconds)
          .onError((error, stackTrace) => 0);
      logger.v('Duration: $duration');
      if (duration == 0.0) {
        // If we failed to fetch the duration, just return the default SVG
        return CAssetImage(path: cat.getRelevantImagePath());
      }
      var b = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: maxWidth ?? width.toInt(),
        maxHeight: maxHeight ?? height.toInt(),
        quality: 25,
        timeMs: duration ~/ 2,
      );
      if (b == null) {
        // If we failed to fetch the thumbnail, just return the default SVG
        return CAssetImage(path: cat.getRelevantImagePath());
      }
      return Image.memory(
        b,
        width: width,
        height: height,
      );
    case SearchCategory.Audio:
    case SearchCategory.Document:
    case SearchCategory.App:
    case SearchCategory.Unknown:
      return CAssetImage(path: cat.getRelevantImagePath());
  }
}

/// Invokes ReplicaUploader.uploadFile
/// Shows "Upload started" notification
/// Pops router until root
// TODO <08-08-22, kalli> Confirm our extension/naming strategy
Future<void> handleUploadConfirm({
  required BuildContext context,
  required File fileToUpload,
  required String fileTitle,
  String? fileDescription,
}) async {
  await ReplicaUploader.inst.uploadFile(
    file: fileToUpload,
    fileName: '$fileTitle${path.extension(fileToUpload.path)}',
    fileDescription: fileDescription,
  );
  // TODO <08-08-22, kalli> Upload notifications pattern will be updated in subsequent ticket
  BotToast.showText(text: 'upload_started'.i18n);
  context.router.popUntilRoot();
}

/// Renders an error message when necessary
Widget renderReplicaErrorUI({required String text, Color? color}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CAssetImage(path: ImagePaths.error, size: 72, color: color ?? black),
      Padding(
        padding: const EdgeInsetsDirectional.all(24.0),
        child: CText(
          text,
          style: tsBody1.copiedWith(color: color ?? black),
          textAlign: TextAlign.center,
        ),
      )
    ],
  );
}
