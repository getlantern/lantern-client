import 'package:file_picker/file_picker.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// renderReplicaLongPressMenuItem is used for rendering list/grid items located
// in the ./ui/replica/listitems directory
SizedBox renderReplicaLongPressMenuItem(ReplicaApi api, ReplicaLink link) {
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
            },
          ),
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
          await api.download(link);
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
      agreeAction: () => context.pushRoute(
        ReplicaUploadFileScreen(
          fileToUpload: file,
        ),
      ),
    );
  }
}
