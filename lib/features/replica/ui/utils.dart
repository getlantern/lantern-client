import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:lantern/features/replica/common.dart';
import 'package:lantern/features/vpn/vpn.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
              showSnackbar(context: context, content: 'download_started'.i18n);
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

  // <07-09-2022, kalli> This is useful code, and while the designs don't call for this right now, I'm keeping it in.
  // final suppressUploadWarning = await replicaModel.getSuppressUploadWarning();
  // if (suppressUploadWarning == true) {
  //   // Immediately proceed to upload screen
  //   await context.pushRoute(
  //     ReplicaUploadTitle(
  //       fileToUpload: file,
  //     ),
  //   );
  // } else {
  //   // Warn user about dangers of uploading first, then proceed to upload screen
  //   CDialog(
  //     title: 'replica_upload_confirmation_title'.i18n,
  //     description: 'replica_upload_confirmation_body'.i18n,
  //     checkboxLabel: 'dont_show_me_this_again'.i18n,
  //     agreeText: 'replica_upload_confirmation_agree'.i18n,
  //     maybeAgreeAction: (doNotShowAgain) async {
  //       if (doNotShowAgain == true) {
  //         await replicaModel.setSuppressUploadWarning(true);
  //       }
  //       await context.pushRoute(
  //         ReplicaUploadTitle(
  //           fileToUpload: file,
  //         ),
  //       );
  //       return true;
  //     },
  //   ).show(context);
  // }

  // We immediately proceed to upload flow since the disclaimer is part of that flow now
  await context.pushRoute(
    ReplicaUploadTitle(
      fileToUpload: file,
    ),
  );
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
      // <08-08-22, kalli> Seems a bit hacky to me
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
      return CAssetImage(size: width, path: cat.getRelevantImagePath());
    case SearchCategory.News:
      return CAssetImage(size: width, path: cat.getRelevantImagePath());
  }
}

/// Invokes ReplicaUploader.uploadFile
/// Shows "Upload started" notification
/// Pops router until root
/// fileTitle: whatever the "name your file" field shows on submit, no extension
/// fileName: fileTitle + extension (automatically generated from fileToUpload)
Future<void> handleUploadConfirm({
  required BuildContext context,
  required File fileToUpload,
  required String fileTitle,
  String? fileDescription,
}) async {
  try {
    await ReplicaUploader().uploadFile(
      file: fileToUpload,
      fileName: '$fileTitle${path.extension(fileToUpload.path)}',
      fileDescription: fileDescription,
      fileTitle: fileTitle,
    );
    showSnackbar(context: context, content: 'upload_started'.i18n);
    context.router.popUntilRoot();
  } catch (e) {
    logger.e('Error uploading: $e');
    showSnackbar(context: context, content: 'upload_unknown_error'.i18n);
  }
}

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
  double? width,
}) {
  return Flexible(
    fit: FlexFit.tight,
    child: ClipRRect(
      borderRadius: defaultBorderRadius,
      clipBehavior: Clip.antiAlias,
      // <08-22-22, kalli> Keeps throwing uncaught exceptions
      // See https://github.com/Baseflow/flutter_cached_network_image/issues/273 - really annoying!! 😠
      // Maybe try this: https://github.com/Baseflow/flutter_cached_network_image/issues/536#issuecomment-1216715184
      child: CachedNetworkImage(
        key: ValueKey<String>(imageUrl),
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) {
          return Image(
            image: imageProvider,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            width: width ?? MediaQuery.of(context).size.width,
          );
        },
        progressIndicatorBuilder: (context, url, downloadProgress) => Container(
          color: grey4,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
                color: white,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          logger.e(error);
          return Stack(
            children: [
              Container(color: grey4),
              const Center(
                child: CAssetImage(
                  path: ImagePaths.image_inactive,
                  size: 24,
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

/// Receives a filename and a scaleBy factor
/// Renders an extension-specific color gradient
Widget renderMimeIcon(String filename, double scaleBy) {
  final fileExtension = getExtension(filename).toLowerCase();
  return SizedBox(
    height: 60,
    width: 60,
    child: ClipRRect(
      borderRadius: defaultBorderRadius,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: getReplicaExtensionBgDecoration(fileExtension),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(8.0),
            child: CText(
              fileExtension.isNotEmpty ? fileExtension : '?',
              style: tsButtonWhite.copiedWith(fontSize: 12 * (scaleBy)),
            ),
          )
        ],
      ),
    ),
  );
}

/// Renders an animated hash-specific color gradient with mime icon
Widget renderAnimatedMimeIcon(
  String filename,
  ReplicaLink replicaLink,
  double animatedValue,
) {
  final fileExtension = getExtension(filename).toLowerCase();
  return SizedBox(
    height: 60,
    width: 60,
    child: ClipRRect(
      borderRadius: defaultBorderRadius,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: getReplicaHashAnimatedBgDecoration(
              replicaLink.infohash,
              animatedValue,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(8.0),
            child: CText(
              fileExtension.isNotEmpty ? fileExtension : '?',
              style: tsButtonWhite.copiedWith(fontSize: 24, lineHeight: 24),
            ),
          )
        ],
      ),
    ),
  );
}

/// Renders a hash-specific color gradient with play icon
Widget renderPlayIcon(ReplicaLink replicaLink) {
  return SizedBox(
    width: 60,
    height: 60,
    child: ClipRRect(
      borderRadius: defaultBorderRadius,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: getReplicaHashBgDecoration(replicaLink.infohash),
          ),
          PlayButton(custom: true),
        ],
      ),
    ),
  );
}

// getextension from filenames
String getExtension(String filename) {
  final index = filename.lastIndexOf('.');
  return index >= 0 ? filename.substring(index, filename.length) : '';
}

Future handleDownload(
  BuildContext context,
  ReplicaSearchItem item,
  ReplicaApi replicaApi,
) async {
  try {
    await replicaApi.download(item.replicaLink);
    showSnackbar(context: context, content: 'download_started'.i18n);
  } catch (e) {
    await showDialog(
      context: context,
      builder: (context) {
        return CDialog(
          title: 'error'.i18n,
          description: 'download_unknown_error'.i18n.fill([item.fileNameTitle]),
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

Widget renderErrorViewingFile(
  BuildContext context,
  ReplicaSearchItem item,
  ReplicaApi replicaApi,
) =>
    Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CText(
            'preview_not_available'.i18n,
            style: tsHeading1,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 16.0,
              bottom: 16.0,
            ),
            child: CText(
              'download_to_view'.i18n,
              style: tsSubtitle1Short,
            ),
          ),
          Button(
            text: 'download'.i18n,
            iconPath: ImagePaths.file_download,
            secondary: true,
            onPressed: () => handleDownload(
              context,
              item,
              replicaApi,
            ),
          )
        ],
      ),
    );

String humanizeCreationDate(BuildContext context, String creationDate) {
  if (creationDate.isEmpty) return '';
  final dateFormat =
      DateFormat.yMd(Localizations.localeOf(context).languageCode);
  final humanizedCreationDate = DateTime.parse(creationDate);
  final formattedDate = dateFormat.format(humanizedCreationDate);
  return 'replica_layout_creation_date'.i18n.fill([formattedDate]);
}

class CustomCacheManager {
  static final CustomCacheManager _instance = CustomCacheManager._internal();

  CustomCacheManager._internal();

  factory CustomCacheManager() {
    return _instance;
  }

  static const key = 'replica_image_cache_manager';
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100 MB cache limit

  static CacheManager customCacheInstance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 3),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  Future<void> _cleanUpCache() async {
    final cacheManager = DefaultCacheManager();
    await cacheManager.emptyCache();
  }

  Future<void> clearCacheIfExceeded() async {
    final cacheDir = await getTemporaryDirectory();
    final cacheSize = _calculateCacheSize(cacheDir);

    if (cacheSize > _maxCacheSize) {
      _cleanUpCache();
      appLogger.i('Cache cleared due to exceeding limit.');
    } else {
      appLogger.i('Cache size within limit: $cacheSize bytes.');
    }
  }

  int _calculateCacheSize(FileSystemEntity file) {
    if (file is File) {
      return file.lengthSync();
    } else if (file is Directory) {
      int sum = 0;
      List<FileSystemEntity> children = file.listSync();
      for (FileSystemEntity child in children) {
        sum += _calculateCacheSize(child);
      }
      return sum;
    }
    return 0;
  }
}
