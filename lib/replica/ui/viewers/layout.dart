import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

/// Base layout class for Replica viewers. It is extended by:
/// replica/ui/viewers/audio
/// replica/ui/viewers/image
/// replica/ui/viewers/misc
/// replica/ui/viewers/video
abstract class ReplicaViewerLayout extends StatefulWidget {
  final ReplicaApi replicaApi;
  final ReplicaSearchItem item;
  final SearchCategory category;

  ReplicaViewerLayout({
    required this.replicaApi,
    required this.item,
    required this.category,
  });
}

abstract class ReplicaViewerLayoutState extends State<ReplicaViewerLayout> {
  // initialize to the fallback metaTitle and metaDescription
  late String infoTitle = widget.item.fileNameTitle;
  late String infoDescription = widget.item.metaDescription;
  // late String infoCreationDate = '';

  @override
  void initState() {
    super.initState();
    // For the Viewers in Replica, we are sending another request to fetch the below params.
    // That request goes to `/object_info` endpoint (as opposed it coming bundled in our ReplicaSearchItem)
    doFetchObjectInfo();
  }

  void doFetchObjectInfo() async {
    await widget.replicaApi
        .fetchObjectInfo(widget.item.replicaLink)
        .then((ReplicaObjectInfo value) {
      setState(() {
        infoTitle = value.infoTitle.isNotEmpty
            ? value.infoTitle
            : widget.item.metaTitle.isNotEmpty
                ? widget.item.metaTitle
                : widget.item.fileNameTitle;
        infoDescription = value.infoDescription.isNotEmpty
            ? value.infoDescription
            : widget.item.metaDescription.isNotEmpty
                ? widget.item.metaDescription
                : 'empty_description'.i18n;
        // infoCreationDate = value.infoCreationDate;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool ready();

  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      showAppBar: true,
      padHorizontal: true,
      title: Container(
        padding: const EdgeInsetsDirectional.only(
          bottom: 6.0,
        ),
        alignment: Alignment.centerLeft,
        child: ready()
            ? (widget.item.primaryMimeType != null)
                ? CText(
                    'replica_layout_filetype'
                        .i18n
                        .fill([widget.item.primaryMimeType!]),
                    style: tsSubtitle1,
                  )
                : CText(
                    widget.category.toShortString(),
                    style: tsSubtitle1,
                  )
            : CText(
                'Unknown'.i18n,
                style: tsSubtitle1,
              ),
      ),
      actions: [
        if (ready())
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsetsDirectional.only(
              end: 12.0,
            ),
            child: CText(
              widget.item.humanizedFileSize,
              style: tsButton,
            ),
          ),
      ],
      body: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 12.0,
          end: 12.0,
          top: 24.0,
        ),
        child: ready()
            // * Render media preview
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(flex: 1, child: body(context)),
                  renderText(),
                ],
              )
            // * Error handling
            : renderErrorViewingFile(
                context,
                widget.item,
                widget.replicaApi,
              ),
      ),
    );
  }

  Widget renderText() {
    return Flexible(
      flex: 1,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // * Title
            Container(
              padding: const EdgeInsetsDirectional.only(
                top: 24.0,
                bottom: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CText(
                      removeExtension(infoTitle),
                      style: tsHeading3,
                    ),
                  ),
                  IconButton(
                    onPressed: () => handleDownload(
                      context,
                      widget.item,
                      widget.replicaApi,
                    ),
                    icon: const CAssetImage(
                      size: 20,
                      path: ImagePaths.file_download,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: black,
            ),
            // * Description
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsetsDirectional.only(
                top: 24.0,
                bottom: 64.0,
              ),
              child: CText(
                infoDescription,
                style: infoDescription.isEmpty
                    ? tsSubtitle1.copiedWith(
                        fontStyle: FontStyle.italic,
                        color: grey4,
                      )
                    : tsSubtitle1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
