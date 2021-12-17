import 'package:file_picker/file_picker.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/uploader.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaHomeScreen is the entrypoint for the user to search through Replica.
/// See docs/replica_home.png for a preview
class ReplicaHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReplicaHomeScreenState();
}

class _ReplicaHomeScreenState extends State<ReplicaHomeScreen> {
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    ReplicaUploader.inst.init();
    super.initState();
  }

  // Two ways to navigate to seach screen:
  // - Click the magnifier icon next to the search bar
  // - Or, just click enter in the search bar
  Future<void> _navigateToSearchScreen(String query) async {
    await context.pushRoute(ReplicaSearchScreen(searchQuery: query));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Dismiss keyboard when clicking anywhere
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: BaseScreen(
            actionButton: renderFap(context),
            centerTitle: true,
            title: 'discover'.i18n,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [renderSearchBar(), renderDescription()],
            )));
  }

  Widget renderDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
      child: CText('replica_search_intro'.i18n, style: tsBody1),
    );
  }

  Widget renderSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: _textEditingController,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (query) async {
          await _navigateToSearchScreen(query);
        },
        decoration: InputDecoration(
          labelText: 'search'.i18n,
          suffixIcon: Material(
            color: blue4,
            child: IconButton(
                onPressed: () async {
                  await _navigateToSearchScreen(_textEditingController.text);
                },
                icon: const Icon(Icons.search),
                color: white),
          ),
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: grey3,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: blue4,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  FloatingActionButton renderFap(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: black,
      child: const CAssetImage(
        path: ImagePaths.file_upload,
      ),
      onPressed: () async {
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
            agreeAction: () => ReplicaUploader.inst.uploadFile(file),
          );
        }
      },
    );
  }
}
