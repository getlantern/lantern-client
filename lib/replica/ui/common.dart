import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:lantern/common/ui/base_screen.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

Widget renderReplicaMediaScreen({
  required BuildContext context,
  required ReplicaApi api,
  required ReplicaLink link,
  required SearchCategory category,
  required Widget body,
  required Color bodyBackgroundColor,
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
      bodyBackgroundColor: bodyBackgroundColor,
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
