import 'package:flutter/material.dart';
import 'package:lantern/common/ui/base_screen.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/custom/list_item_factory.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/common/ui/text_styles.dart';
import 'package:lantern/i18n/i18n.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

SizedBox renderReplicaLongPressMenuItem(ReplicaApi api, ReplicaLink link) {
  return SizedBox(
    height: 96,
    child: Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListItemFactory.focusMenuItem(
              icon: ImagePaths.file_download,
              content: 'Download'.i18n,
              onTap: () async {
                await api.download(link);
              }),
          ListItemFactory.focusMenuItem(
              icon: ImagePaths.share,
              content: 'Share'.i18n,
              onTap: () async {
                await Share.share(link.toMagnetLink());
              }),
        ],
      ),
    ),
  );
}

Widget renderReplicaMediaScreen({
  required BuildContext context,
  required ReplicaApi api,
  required ReplicaLink link,
  required SearchCategory category,
  required Widget body,
  required Color backgroundColor,
  String? mimeType,
}) {
  return BaseScreen(
      showAppBar: true,
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
              category.toShortString(),
              style: CTextStyle(fontSize: 9, lineHeight: 12.0),
            )
        ],
      ),
      backgroundColor: backgroundColor,
      actions: [
        IconButton(
            onPressed: () async {
              await Share.share(link.toMagnetLink());
            },
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
      body: body);
}
