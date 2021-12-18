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
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// renderReplicaLongPressMenuItem is used for rendering list/grid items located
// in the ./ui/replica/listitems directory
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
              content: 'download'.i18n,
              onTap: () async {
                await api.download(link);
              }),
          ListItemFactory.focusMenuItem(
              icon: ImagePaths.share,
              content: 'share'.i18n,
              onTap: () async {
                await Share.share('replica://${link.toMagnetLink()}');
              }),
        ],
      ),
    ),
  );
}

// renderReplicaMediaViewScreen is used as the root widget for all Replica media
// views (located in ./ui/replica/media_views directory)
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
              await Share.share(link.toMagnetLink());
            },
            icon: CAssetImage(
              size: 20,
              path: ImagePaths.share,
              color: foregroundColor,
            )),
        IconButton(
            onPressed: () async {
              await api.download(link);
            },
            icon: CAssetImage(
              size: 20,
              path: ImagePaths.file_download,
              color: foregroundColor,
            )),
      ],
      body: body);
}

final String replica_upload_disclaimer_value_shared_prefs_name =
    'replica_upload_disclaimer_checkbox_value';

Future<bool> getReplicaUploadDisclaimerCheckboxValue() async {
  var prefs = await SharedPreferences.getInstance();
  return prefs.getBool(replica_upload_disclaimer_value_shared_prefs_name) ??
      false;
}

Future<void> setReplicaUploadDisclaimerCheckboxValue(bool b) async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.setBool(replica_upload_disclaimer_value_shared_prefs_name, b);
}
