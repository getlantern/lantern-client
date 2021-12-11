import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// TODO Replace all usages of this into just api.download
// getCommonDownloadBtnPressedClosure is a function returning a closure that
// includes 'item'. This closure handles the most common download task:
// - queue a download for a Replica link
// - show a notification at the beginning of the download with a progress bar
// - show a notification at the end of the download mentionin it is downloaded
//   successfully

Function() getCommonOnShareBtnPressedClosure(
    BuildContext context, ReplicaLink? link) {
  if (link == null) {
    // If link is null, do nothing.
    return () {};
  }
  return () async {
    await FlutterShare.share(
        title: 'Lantern',
        text: 'Share text',
        linkUrl: link.toMagnetLink(),
        chooserTitle: 'Example Chooser Title');
  };
}

AppBar renderAppBar(BuildContext context, ReplicaApi api, ReplicaLink link,
    SearchCategory searchCategory, String? mimeType) {
  return AppBar(
    centerTitle: false,
    leadingWidth: 25.0,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CText(
          link.displayName ?? 'Untitled',
          style: CTextStyle(
            fontSize: 16,
            lineHeight: 20.0,
          ),
        ),
        if (mimeType != null)
          CText(
            mimeType,
            style: CTextStyle(fontSize: 9, lineHeight: 12.0),
          )
        else
          CText(
            searchCategory.toShortString(),
            style: CTextStyle(fontSize: 9, lineHeight: 12.0),
          )
      ],
    ),
    backgroundColor: white,
    actions: [
      IconButton(
          onPressed: getCommonOnShareBtnPressedClosure(context, link),
          icon: const CAssetImage(
            size: 20,
            path: ImagePaths.share,
          )),
      IconButton(
          onPressed: () async {
            await api.download(link);
          },
          icon: const CAssetImage(
            size: 20,
            path: ImagePaths.file_download,
          )),
    ],
  );
}
