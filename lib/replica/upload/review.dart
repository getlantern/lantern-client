import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

class ReplicaUploadReview extends StatefulWidget {
  final File fileToUpload;
  final String fileTitle;
  final String fileDescription;

  ReplicaUploadReview({
    Key? key,
    required this.fileToUpload,
    required this.fileTitle,
    required this.fileDescription,
  });

  @override
  State<StatefulWidget> createState() => _ReplicaUploadReviewState();
}

class _ReplicaUploadReviewState extends State<ReplicaUploadReview> {
  final formKey = GlobalKey<FormState>(debugLabel: 'replicaUploadReview');
  late final textEditingController =
      CustomTextEditingController(formKey: formKey);
  late final Future<Widget> getUploadThumbnailFromFileFuture;
  late bool checkboxChecked = false;
  final thumbnailWidth = 110.0;
  final thumbnailHeight = 110.0;

  @override
  void initState() {
    ReplicaUploader.inst.init();

    getUploadThumbnailFromFileFuture = getUploadThumbnailFromFile(
      file: widget.fileToUpload,
      width: thumbnailWidth,
      height: thumbnailHeight,
    );
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
        padHorizontal: true,
        showAppBar: true,
        title: 'review'.i18n,
        body: PinnedButtonLayout(
          content: [
            renderPreview(),
            renderTOS(),
          ],
          button: renderButtons(),
        ),
      ),
    );
  }

  Widget renderPreview() {
    return Container(
      padding: const EdgeInsetsDirectional.only(
        top: 24.0,
      ),
      color: grey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // * Thumbnail
              FutureBuilder(
                future: getUploadThumbnailFromFileFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return CAssetImage(
                      path: SearchCategoryFromMimeType(
                        // TODO <08-09-22, kalli> Fix this path to an always available fallback
                        lookupMimeType(widget.fileToUpload.path) ?? '',
                      ).getRelevantImagePath(),
                    );
                  }
                  return snapshot.data!;
                },
              ),
              //  * File metadata
              Container(
                height: thumbnailHeight,
                padding: const EdgeInsetsDirectional.only(
                  start: 12.0,
                  end: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // * File mimetype
                    // TODO <08-10-22, kalli> Show file type not mime type
                    Container(
                      child:
                          (path.extension(widget.fileToUpload.path).isNotEmpty)
                              ? CText(
                                  path
                                      // TODO <08-08-22, kalli> Confirm our extension/naming strategy
                                      .extension(widget.fileToUpload.path)
                                      .toUpperCase()
                                      .replaceAll('.', ''),
                                  style: tsOverline.copiedWith(color: pink4),
                                )
                              : CText(
                                  'image_unknown'.i18n,
                                  style: tsBody1.copiedWith(color: pink4),
                                ),
                    ),
                    // * File title
                    CText(
                      widget.fileTitle,
                      maxLines: 3,
                      style: tsBody3.copiedWith(color: grey5),
                    )
                  ],
                ),
              ),
              // * Edit metadata
              renderEditIcon(),
            ],
          ),
          //  * File description
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.only(
                    top: 16.0,
                    bottom: 16.0,
                  ),
                  child: CText(
                    widget.fileDescription,
                    style: tsBody2,
                    maxLines: 4,
                  ),
                ),
              ),
              // * Edit metadata
              renderEditIcon(),
            ],
          )
        ],
      ),
    );
  }

  Widget renderEditIcon() {
    return GestureDetector(
      // TODO <08-10-22, kalli> Add edit action handler
      onTap: () {},
      child: Container(
        height: thumbnailHeight,
        child: const CAssetImage(path: ImagePaths.mode_edit),
      ),
    );
  }

  Widget renderTOS() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8.0),
            child: CText(
              'important'.i18n,
              style: tsSubtitle1,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8.0),
            child: CText(
              'replica_upload_confirmation_body'.i18n,
              style: tsBody1,
            ),
          ),
          CInkWell(
            onTap: () => setState(() => checkboxChecked = !checkboxChecked),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  visualDensity: VisualDensity.compact,
                  shape: const RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith(
                    (states) => getCheckboxFillColor(black, states),
                  ),
                  value: checkboxChecked,
                  onChanged: (bool? value) {
                    setState(() => checkboxChecked = value!);
                  },
                ),
                CText(
                  'upload_tos_agree'.i18n,
                  style: tsBody1Short,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget renderButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Button(
          width: 150,
          text: 'cancel'.i18n,
          onPressed: () async => context.router.popUntilRoot(),
          secondary: true,
        ),
        Button(
          disabled: !checkboxChecked,
          width: 150,
          text: 'publish'.i18n,
          onPressed: () async => await handleUploadConfirm(
            context,
            widget.fileToUpload,
            widget.fileTitle,
          ),
        ),
      ],
    );
  }
}
