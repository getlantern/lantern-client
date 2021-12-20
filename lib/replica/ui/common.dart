import 'dart:io';

import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lantern/common/ui/base_screen.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/custom/list_item_factory.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/common/ui/show_confirmation_dialog.dart';
import 'package:lantern/common/ui/text_styles.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/i18n/i18n.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/vpn/vpn.dart';
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
  var file = File(result.files.single.path);
  logger.v('Picked a file $file');

  // If the checkbox value is false, show it
  // If true, don't
  if (!await getReplicaUploadDisclaimerCheckboxValue().timeout(
    const Duration(seconds: 2),
    onTimeout: () => false,
  )) {
    showConfirmationDialog(
      context: context,
      title: 'replica_upload_confirmation_title'.i18n,
      explanation: 'replica_upload_confirmation_body'.i18n,
      agreeText: 'replica_upload_confirmation_agree'.i18n,
      agreeAction: () => context.pushRoute(ReplicaUploadFileScreen(
        fileToUpload: file,
      )),
    );
  }
}

Widget renderReplicaSearchTextField(
    {required Future<void> Function(String query) onPressed,
    required TextEditingController textEditingController}) {
  return TextFormField(
    controller: textEditingController,
    textInputAction: TextInputAction.search,
    style: CTextStyle(color: grey5, fontSize: 16, lineHeight: 20.0),
    onFieldSubmitted: (query) async {
      await onPressed(query);
    },
    decoration: InputDecoration(
      labelText: 'search'.i18n,
      suffixIcon: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(blue4),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.only(
                topEnd: Radius.circular(4),
                bottomEnd: Radius.circular(4),
              ),
            ))),
        onPressed: () async {
          await onPressed(textEditingController.text);
        },
        child: Icon(Icons.search, color: white),
      ),
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: grey3,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: blue4,
          width: 1.0,
        ),
      ),
    ),
  );
}
