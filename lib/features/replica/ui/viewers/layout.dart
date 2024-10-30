import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';

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
  late String infoCreationDate = '';
  late bool infoError = false;
  late bool textCopied = false;

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
      if (value is EmptyReplicaObjectInfo) {
        logger.i('Empty response from object_info');
      }
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
        infoCreationDate = value.infoCreationDate;
      });
      sessionModel.trackUserAction('User viewed Replica content',
          widget.item.replicaLink.toMagnetLink(), infoTitle);
    }).onError((error, stackTrace) {
      logger.v('Could not fetch object_info: $error , $stackTrace');
      setState(() {
        infoError = true;
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
        alignment: Alignment.centerLeft,
        child: ready()
            ? (widget.item.primaryMimeType != null)
                ? CText(
                    'replica_layout_filetype'
                        .i18n
                        .fill([widget.item.primaryMimeType!]),
                    style: tsSubtitle1.copiedWith(
                      color: grey5,
                      lineHeight: 16,
                    ), // line-height for center align
                  )
                : CText(
                    widget.category.toShortString(),
                    style: tsSubtitle1.copiedWith(color: grey5, lineHeight: 16),
                  )
            : CText(
                'Unknown'.i18n,
                style: tsSubtitle1.copiedWith(color: grey5, lineHeight: 16),
              ),
      ),
      actions: [
        if (ready())
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsetsDirectional.only(
              end: 12.0,
            ),
            child: CText(
              widget.item.humanizedFileSize,
              style: tsButton.copiedWith(
                lineHeight: 16,
              ), // line-height for center align matching title
            ),
          ),
      ],
      body: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 4.0,
          end: 4.0,
          top: 24.0,
        ),
        child: ready() & !infoError
            // * Render media preview
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  body(context),
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
      flex: 2,
      child: Column(
        children: [
          // * Title
          Container(
            padding: const EdgeInsetsDirectional.only(
              top: 12.0,
              bottom: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8.0),
                        child: CText(
                          removeExtension(infoTitle),
                          style: tsHeading3,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    CInkWell(
                      onTap: () async {
                        copyText(
                          context,
                          removeExtension(infoTitle),
                        );
                        setState(() => textCopied = true);
                        await Future.delayed(
                          defaultAnimationDuration,
                          () => setState(
                            () => textCopied = false,
                          ),
                        );
                      },
                      child: CAssetImage(
                        size: 20,
                        path: textCopied
                            ? ImagePaths.check_green
                            : ImagePaths.content_copy,
                      ),
                    ),
                    IconButton(
                      onPressed: () => handleDownload(
                        context,
                        widget.item,
                        widget.replicaApi,
                      ),
                      icon: const CAssetImage(
                        size: 24,
                        path: ImagePaths.file_download,
                      ),
                    ),
                  ],
                ),
                CText(
                  humanizeCreationDate(context, infoCreationDate).toUpperCase(),
                  style: tsBody1Short.copiedWith(color: grey5),
                )
              ],
            ),
          ),
          Divider(
            color: grey5,
          ),
          // * Description
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsetsDirectional.only(
                  bottom: 24.0,
                ),
                child: GestureDetector(
                  onTap: () async {
                    copyText(
                      context,
                      infoDescription,
                    );
                  },
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
