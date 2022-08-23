import 'package:file_picker/file_picker.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:lantern/replica/common.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  showSnackbar(context: context, content: 'upload_started'.i18n);
  context.router.popUntilRoot();
}

// TODO <08-18-22, kalli> Render a custom error state
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

/// Used in ReplicaViewerLayout and ReplicaImageListItem to render a thumbnail preview (of variable size) for an image asset
Widget renderImageThumbnail({
  required String imageUrl,
  required ReplicaSearchItem item,
  required double size,
}) {
  return Flexible(
    child: ClipRRect(
      borderRadius: defaultBorderRadius,
      // <08-22-22, kalli> Keeps throwing uncaught exceptions
      // See https://github.com/Baseflow/flutter_cached_network_image/issues/273 - really annoying!! 😠
      // Maybe try this: https://github.com/Baseflow/flutter_cached_network_image/issues/536#issuecomment-1216715184
      child: CachedNetworkImage(
        key: ValueKey<String>(imageUrl),
        imageUrl: imageUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
          padding: const EdgeInsetsDirectional.all(4.0),
          child: CircularProgressIndicator(value: downloadProgress.progress),
        ),
        errorWidget: (context, url, error) {
          logger.e(error);
          return Stack(
            children: [
              Container(color: grey4),
              Center(
                child: CAssetImage(
                  path: ImagePaths.image_inactive,
                  size: size,
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Widget renderMimeIcon(String primaryMimeType) {
  final fileExtension = '.${primaryMimeType.split('/')[1]}';
  return SizedBox(
    width: 60,
    height: 60,
    child: ClipRRect(
      borderRadius: defaultBorderRadius,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: getReplicaMimeBgColor(fileExtension),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(8.0),
            child: CText(
              fileExtension.isNotEmpty ? fileExtension : '?',
              style: tsButtonWhite.copiedWith(fontSize: 12),
            ),
          )
        ],
      ),
    ),
  );
}

Future handleDownload(
  BuildContext context,
  ReplicaSearchItem item,
  ReplicaApi replicaApi,
) async {
  try {
    await replicaApi.download(item.replicaLink);
    // TODO <08-08-22, kalli> Confirm we can use BotToast
    BotToast.showText(text: 'download_started'.i18n);
  } catch (e) {
    await showDialog(
      context: context,
      builder: (context) {
        return CDialog(
          // TODO <08-18-22, kalli> i18n
          title: 'Error downloading ${item.displayName}',
          description: 'Something went wrong!',
        );
      },
    );
  }
}

// remove extension from filenames
String removeExtension(String filename) {
  final index = filename.lastIndexOf('.');
  return index >= 0 ? filename.substring(0, index) : filename;
}
