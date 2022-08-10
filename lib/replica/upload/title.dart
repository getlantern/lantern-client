import 'package:path/path.dart' as path;
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

// ReplicaUploadTitle renders a single-item ListView with the contents of
// 'fileToUpload', allowing the user to change the display name of the upload.
// TODO <08-08-22, kalli> Confirm our extension/naming strategy
class ReplicaUploadTitle extends StatefulWidget {
  final File fileToUpload;

  ReplicaUploadTitle({Key? key, required this.fileToUpload});

  @override
  State<StatefulWidget> createState() => _ReplicaUploadTitleState();
}

class _ReplicaUploadTitleState extends State<ReplicaUploadTitle> {
  final formKey = GlobalKey<FormState>(debugLabel: 'replicaUploadTitle');
  late final textEditingController =
      CustomTextEditingController(formKey: formKey);
  late final String fileTitle;

  @override
  void initState() {
    fileTitle = path.withoutExtension(path.basename(widget.fileToUpload.path));
    textEditingController.text = fileTitle;
    ReplicaUploader.inst.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when clicking anywhere
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: BaseScreen(
        showAppBar: true,
        padHorizontal: true,
        title: 'edit_title'.i18n,
        body: PinnedButtonLayout(
          content: [
            renderEditingNotice(),
            renderTitleField(),
          ],
          button: renderButtons(),
        ),
      ),
    );
  }

  Widget renderEditingNotice() {
    return Container(
      color: grey1,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsetsDirectional.all(10.0),
      margin: const EdgeInsetsDirectional.only(
        top: 24.0,
        bottom: 12.0,
      ),
      child: CText(
        'Filenames cannot be edited once published.',
        style: tsBody1,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget renderTitleField() {
    return CTextField(
      prefixIcon: const CAssetImage(path: ImagePaths.mode_edit),
      keyboardType: TextInputType.text,
      controller: textEditingController,
      label: 'edit_title'.i18n,
      textInputAction: TextInputAction.done,
      contentPadding: const EdgeInsetsDirectional.only(
        top: 12.0,
        bottom: 12.0,
        end: 12.0,
      ),
      onFieldSubmitted: (query) async {
        setState(() {
          fileTitle = query;
        });
      },
    );
  }

  Widget renderButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Button(
          width: 150,
          text: 'publish'.i18n,
          secondary: true,
          onPressed: () async => await handleUploadConfirm(
            context,
            widget.fileToUpload,
            fileTitle,
          ),
        ),
        Button(
          width: 150,
          text: 'add_description'.i18n,
          onPressed: () async => await context.pushRoute(
            ReplicaUploadDescription(
              fileToUpload: widget.fileToUpload,
              fileTitle: fileTitle,
            ),
          ),
        ),
      ],
    );
  }
}
