import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

@RoutePage(name: 'ReplicaUploadReview')
class ReplicaUploadReview extends StatefulWidget {
  final File fileToUpload;
  final String fileTitle;
  final String? fileDescription;

  ReplicaUploadReview({
    Key? key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
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
        padHorizontal: false,
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
        start: 24.0,
        end: 24.0,
      ),
      color: grey1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // * Thumbnail
              FutureBuilder(
                future: getUploadThumbnailFromFileFuture,
                builder: (
                  BuildContext thumbnailContext,
                  AsyncSnapshot<Widget> snapshot,
                ) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return CAssetImage(
                      size: thumbnailWidth,
                      path: SearchCategoryFromMimeType(
                        lookupMimeType(widget.fileToUpload.path),
                      ).getRelevantImagePath(),
                    );
                  }
                  return snapshot.data!;
                },
              ),
              //  * File metadata
              Expanded(
                child: Container(
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
                      Container(
                        child: (path
                                .extension(widget.fileToUpload.path)
                                .isNotEmpty)
                            ? CText(
                                path
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
              ),
              // * Edit metadata
              renderEditIcon(
                // onTap action
                () async => await context.router.push(
                  ReplicaUploadTitle(
                    fileToUpload: widget.fileToUpload,
                    fileTitle: widget.fileTitle,
                    fileDescription: widget.fileDescription,
                  ),
                ),
              ),
            ],
          ),
          //  * File description
          Row(
            children: [
              Expanded(
                child: CText(
                  widget.fileDescription != null &&
                          widget.fileDescription!.isNotEmpty
                      ? widget.fileDescription!
                      : 'add_description'.i18n.toUpperCase(),
                  style: widget.fileDescription != null &&
                          widget.fileDescription!.isNotEmpty
                      ? tsBody2
                      : tsBody2.copiedWith(
                          color: grey5,
                        ),
                  maxLines: 4,
                ),
              ),
              // * Edit metadata
              renderEditIcon(
                // onTap action
                () async => await context.router.push(
                  ReplicaUploadDescription(
                    fileToUpload: widget.fileToUpload,
                    fileTitle: widget.fileTitle,
                    fileDescription: widget.fileDescription,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget renderEditIcon(Function onTap) {
    return Container(
      height: thumbnailHeight,
      child: CInkWell(
        onTap: () => onTap(),
        child: const CAssetImage(path: ImagePaths.mode_edit),
      ),
    );
  }

  Widget renderTOS() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 24.0,
        end: 24.0,
        top: 24.0,
      ),
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
              style: tsBody1.copiedWith(fontStyle: FontStyle.italic),
            ),
          ),
          CInkWell(
            onTap: () => setState(() => checkboxChecked = !checkboxChecked),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: SizedBox(
                    width: 20.0, // hack to rm checkbox left paddings
                    child: Checkbox(
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
                  ),
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
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 24.0, end: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Button(
            width: MediaQuery.of(context).size.width * 0.4,
            text: 'cancel'.i18n,
            onPressed: () async => context.router.popUntilRoot(),
            secondary: true,
          ),
          Button(
            width: MediaQuery.of(context).size.width * 0.4,
            disabled: !checkboxChecked,
            text: 'publish'.i18n,
            onPressed: () async => await handleUploadConfirm(
              context: context,
              fileToUpload: widget.fileToUpload,
              fileTitle: widget.fileTitle,
              fileDescription: widget.fileDescription,
            ),
          ),
        ],
      ),
    );
  }
}
