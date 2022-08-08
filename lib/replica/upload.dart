import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

// ReplicaUploadFileScreen renders a single-item ListView with the contents of
// 'fileToUpload', allowing the user to change the display name of the upload.
// TODO <08-08-22, kalli> Will be completely overhauled
class ReplicaUploadFileScreen extends StatefulWidget {
  final File fileToUpload;

  ReplicaUploadFileScreen({Key? key, required this.fileToUpload});

  @override
  State<StatefulWidget> createState() => _ReplicaUploadFileScreenState();
}

class _ReplicaUploadFileScreenState extends State<ReplicaUploadFileScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'replicaUploadFileInput');
  late final _textEditingController =
      CustomTextEditingController(formKey: _formKey);
  late String _displayName;
  late final Future<Widget> _getThumbnailWidgetFromFileFuture;

  @override
  void initState() {
    _displayName =
        path.withoutExtension(path.basename(widget.fileToUpload.path));
    _textEditingController.text = _displayName;
    ReplicaUploader.inst.init();

    _getThumbnailWidgetFromFileFuture =
        _getThumbnailWidgetFromFile(widget.fileToUpload);
    super.initState();
  }

  Widget renderSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 30.0),
      child: CTextField(
        prefixIcon: const CAssetImage(path: ImagePaths.mode_edit),
        keyboardType: TextInputType.text,
        controller: _textEditingController,
        // TODO <08-08-22, kalli> Confirm our extension/naming strategy
        label: 'name_your_file'.i18n,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (query) async {
          setState(() {
            _displayName = query;
          });
        },
      ),
    );
  }

  Future<Widget> _getThumbnailWidgetFromFile(File file) async {
    var cat = SearchCategoryFromMimeType(lookupMimeType(file.path));
    switch (cat) {
      case SearchCategory.Image:
        return Image.file(
          file,
          width: 24,
          height: 24,
          filterQuality: FilterQuality.medium,
        );
      case SearchCategory.Video:
        // We're using VideoPlayerController to get the duration of the video,
        // which we'll use to pick a thumbnail in the middle
        // TODO <08-08-22, kalli> Seems a bit hacky to me
        var c = VideoPlayerController.file(file);
        var duration = await c
            .initialize()
            .then((_) => c.value.duration.inMilliseconds)
            .onError((error, stackTrace) => 0);
        logger.v('Duration: $duration');
        if (duration == 0.0) {
          // If we failed to fetch the duration, just return the default SVG
          return CAssetImage(path: cat.getRelevantImagePath());
        }
        var b = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 24,
          maxHeight: 24,
          quality: 25,
          timeMs: duration ~/ 2,
        );
        if (b == null) {
          // If we failed to fetch the thumbnail, just return the default SVG
          return CAssetImage(path: cat.getRelevantImagePath());
        }
        return Image.memory(
          b,
          width: 24,
          height: 24,
        );
      case SearchCategory.Audio:
      case SearchCategory.Document:
      case SearchCategory.App:
      case SearchCategory.Unknown:
        return CAssetImage(path: cat.getRelevantImagePath());
    }
  }

  // TODO <08-08-22, kalli> Pretty sure this isn't actually used? We never show a list of uploads 🤔
  Widget renderUploadList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        // Shrinkwrap is true for convenience since this will always be a
        // single element list
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // First element should be a divider
          if (index == 0) {
            return const Divider(height: 1, thickness: 1);
          }
          return ListItemFactory.uploadEditItem(
            trailingArray: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const CAssetImage(path: ImagePaths.trailing_icon),
              )
            ],
            leading: FutureBuilder(
              future: _getThumbnailWidgetFromFileFuture,
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return CAssetImage(
                    path: SearchCategoryFromMimeType(
                      lookupMimeType(widget.fileToUpload.path) ?? '',
                    ).getRelevantImagePath(),
                  );
                }

                return snapshot.data!;
              },
            ),
            // leading: const CAssetImage(path: ImagePaths.spreadsheet),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              verticalDirection: VerticalDirection.down,
              children: [
                CText(
                  _displayName,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: tsSubtitle1Short,
                ),
                // Render mime type
                // If mimetype is nil, just render 'app/unknown'
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                    ),
                    // TODO <08-08-22, kalli> Confirm our extension/naming strategy
                    if (path.extension(widget.fileToUpload.path).isNotEmpty)
                      CText(
                        path
                            // TODO <08-08-22, kalli> Confirm our extension/naming strategy
                            .extension(widget.fileToUpload.path)
                            .toUpperCase()
                            .replaceAll('.', ''),
                        style: tsBody1.copiedWith(color: pink4),
                      )
                    else
                      CText(
                        'image_unknown'.i18n,
                        style: tsBody1.copiedWith(color: pink4),
                      ),
                  ],
                )
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemCount: 2,
      ),
    );
  }

  Widget renderUploadButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        child: Button(
          width: 200,
          text: 'upload'.i18n,
          onPressed: () async {
            await ReplicaUploader.inst.uploadFile(
              widget.fileToUpload,
              // TODO <08-08-22, kalli> Confirm our extension/naming strategy
              // Add the display name with the extension
              '$_displayName${path.extension(widget.fileToUpload.path)}',
            );
            // TODO <08-08-22, kalli> Confirm we can use BotToast
            BotToast.showText(text: 'upload_started'.i18n);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
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
        title: 'upload_file_screen'.i18n,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              renderSearchBar(),
              renderUploadList(),
              renderUploadButton()
            ],
          ),
        ),
      ),
    );
  }

// agreeAction: () => ,
}
