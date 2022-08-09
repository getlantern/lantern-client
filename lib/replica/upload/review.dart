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

  @override
  void initState() {
    ReplicaUploader.inst.init();

    getUploadThumbnailFromFileFuture =
        getUploadThumbnailFromFile(widget.fileToUpload);
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              renderPreview(),
              renderTOS(),
              renderPublishButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderPreview() {
    return Container(
      color: grey1,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // TODO <08-08-22, kalli> Confirm our extension/naming strategy
                      if (path.extension(widget.fileToUpload.path).isNotEmpty)
                        CText(
                          path
                              // TODO <08-08-22, kalli> Confirm our extension/naming strategy
                              .extension(widget.fileToUpload.path)
                              .toUpperCase()
                              .replaceAll('.', ''),
                          style: tsOverline.copiedWith(color: pink4),
                        )
                      else
                        CText(
                          'image_unknown'.i18n,
                          style: tsBody1.copiedWith(color: pink4),
                        ),
                    ],
                  ),
                  // Render mime type
                  // If mimetype is nil, just render 'app/unknown'
                  // TODO <08-09-22, kalli> Fix overflows
                  CText(
                    widget.fileTitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: tsBody3,
                  )
                ],
              )
            ],
          ),
          // TODO <08-09-22, kalli> Remove placeholder
          CText(
            'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
            style: tsBody2,
          )
        ],
      ),
    );
  }

  Widget renderTOS() {
    return Column(
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
    );
  }

  Widget renderPublishButton() {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Button(
            width: 150,
            text: 'cancel'.i18n,
            onPressed: () async => context.router.popUntilRoot(),
            secondary: true,
          ),
          Button(
            width: 150,
            text: 'publish'.i18n,
            onPressed: () async {
              await ReplicaUploader.inst.uploadFile(
                widget.fileToUpload,
                // TODO <08-08-22, kalli> Confirm our extension/naming strategy
                '$widget.fileTitle${path.extension(widget.fileToUpload.path)}',
              );
              // TODO <08-08-22, kalli> Confirm we can use BotToast
              BotToast.showText(text: 'upload_started'.i18n);
              context.router.popUntilRoot();
            },
          ),
        ],
      ),
    );
  }
}
