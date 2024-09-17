import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:path/path.dart' as path;

// ReplicaUploadTitle renders a single-item ListView with the contents of
// 'fileToUpload', allowing the user to change the display name of the upload.
@RoutePage(name: 'ReplicaUploadTitle')
class ReplicaUploadTitle extends StatefulWidget {
  final File fileToUpload;
  final String? fileTitle;
  final String? fileDescription;

  ReplicaUploadTitle({
    Key? key,
    required this.fileToUpload,
    this.fileTitle,
    this.fileDescription,
  });

  @override
  State<StatefulWidget> createState() => _ReplicaUploadTitleState();
}

class _ReplicaUploadTitleState extends State<ReplicaUploadTitle> {
  final formKey = GlobalKey<FormState>(debugLabel: 'replicaUploadTitle');
  late final textEditingController =
      CustomTextEditingController(formKey: formKey);
  late final String fileTitle;
  late bool disabled = false;

  @override
  void initState() {
    fileTitle = path.withoutExtension(path.basename(widget.fileToUpload.path));
    textEditingController.text = widget.fileTitle ?? fileTitle;
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
      color: grey2,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsetsDirectional.all(10.0),
      margin: const EdgeInsetsDirectional.only(
        top: 24.0,
        bottom: 12.0,
      ),
      child: CText(
        'filenames_cannot_be_edited'.i18n,
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
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
      contentPadding: const EdgeInsetsDirectional.only(
        top: 12.0,
        bottom: 12.0,
        end: 12.0,
      ),
      onChanged: (text) async {
        setState(() => disabled = text == '');
      },
    );
  }

  Widget renderButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Button(
        //   width: 150,
        //   text: 'skip'.i18n,
        //   secondary: true,
        //   disabled: disabled,
        //   onPressed: () async => await context.pushRoute(
        //     ReplicaUploadReview(
        //       fileToUpload: widget.fileToUpload,
        //       fileTitle: textEditingController.text,
        //       fileDescription: widget.fileDescription,
        //     ),
        //   ),
        // ),
        Button(
          text: 'next'.i18n,
          disabled: disabled,
          onPressed: () async => await context.pushRoute(
            ReplicaUploadDescription(
              fileToUpload: widget.fileToUpload,
              fileTitle: textEditingController.text,
              fileDescription: widget.fileDescription,
            ),
          ),
        ),
      ],
    );
  }
}
