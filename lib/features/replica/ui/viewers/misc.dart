import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lantern/core/utils/common.dart';
import 'package:lantern/features/replica/common.dart';
import 'package:lantern/features/replica/ui/viewers/layout.dart';
import 'package:path_provider/path_provider.dart';

/// Multi-purpose class which renders a Replica viewer for
/// 1. Documents
/// 2. Apps
/// 3. Unknown
/// It does not offer a full screen option unless we have a PDF
@RoutePage(name: 'ReplicaMiscViewer')
class ReplicaMiscViewer extends ReplicaViewerLayout {
  ReplicaMiscViewer({
    required ReplicaApi replicaApi,
    required ReplicaSearchItem item,
    required SearchCategory category,
  }) : super(replicaApi: replicaApi, item: item, category: category);

  @override
  State<StatefulWidget> createState() => _ReplicaMiscViewerState();
}

class _ReplicaMiscViewerState extends ReplicaViewerLayoutState {
  String? tempFilePath;
  late bool isPDF = false;
  var hasError = false;

  @override
  void initState() {
    super.initState();
    isPDF = widget.item.primaryMimeType == 'application/pdf';
    if (isPDF) {
      // Fetch the PDF to an application-specific temp file so that we can open it
      // in a PDFView.
      getTemporaryDirectory().then((tempDir) {
        setState(() {
          tempFilePath =
              '${tempDir.absolute.path}/${widget.item.replicaLink.infohash}';
        });
      });
    }
  }

  @override
  void dispose() {
    // Delete the temp PDF file when we're done viewing it.
    if (isPDF && tempFilePath != null) {
      try {
        File(tempFilePath!).deleteSync();
      } catch (e) {
        logger.e(
          'Something went wrong while deleting the temporary PDF after viewing it $e',
        );
      }
    }
    super.dispose();
  }

  @override
  bool ready() => true;

  @override
  Widget body(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.loose,
        children: [
          Container(
            height: 150,
            width: 150,
            child: GestureDetector(
              child: renderMimeIcon(widget.item.fileNameTitle, 2.0),
              onTap: () async {
                if (isPDF && tempFilePath != null) {
                  // open full screen dialog with PDF viewer
                  await context.router.push(
                    FullScreenDialogPage(
                      widget: FutureBuilder(
                        // download to local file path
                        future: widget.replicaApi
                            .fetch(widget.item.replicaLink, tempFilePath!),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return BaseScreen(
                                title: widget.item.fileNameTitle,
                                body: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            default:
                              if (snapshot.hasError) {
                                setState(() {
                                  hasError = true;
                                });
                                return BaseScreen(
                                  title: widget.item.fileNameTitle,
                                  body: renderErrorViewingFile(
                                    context,
                                    widget.item,
                                    widget.replicaApi,
                                  ),
                                );
                              } else {
                                return PDFScreen(
                                  path: tempFilePath!,
                                  item: widget.item,
                                  replicaApi: widget.replicaApi,
                                  hasError: hasError,
                                );
                              }
                          }
                        },
                      ),
                    ),
                  );
                }

              },
            ),
          ),
          if (isPDF)
            IgnorePointer(
              // pass gesture to mime icon
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: InfoTextBox(
                  text: 'read_details'.i18n.toUpperCase(),
                  invertColors: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String path;
  final ReplicaSearchItem item;
  final ReplicaApi replicaApi;
  final bool hasError;

  PDFScreen({
    Key? key,
    required this.path,
    required this.item,
    required this.replicaApi,
    required this.hasError,
  }) : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      padHorizontal: false,
      padVertical: true,
      title: widget.item.fileNameTitle,
      actionButton: (errorMessage.isEmpty)
          ? FutureBuilder<PDFViewController>(
              future: _controller.future,
              builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                if (snapshot.hasData) {
                  return InfoTextBox(
                    text: '${currentPage! + 1} / $pages',
                  );
                }
                return Container();
              },
            )
          : Container(),
      body: PDFView(
        filePath: widget.path,
        enableSwipe: true,
        // swipeHorizontal: true,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        fitEachPage: true,
        defaultPage: currentPage!,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
        // if set to true the link is handled in flutter
        onRender: (_pages) {
          setState(() {
            pages = _pages;
          });
        },
        onError: (error) {
          setState(() {
            errorMessage = error.toString();
          });
          logger.e(error);
        },
        onViewCreated: (PDFViewController pdfViewController) {
          _controller.complete(pdfViewController);
        },
        onLinkHandler: (String? uri) {
          print('goto uri: $uri');
        },
        onPageChanged: (int? page, int? total) {
          setState(() {
            currentPage = page;
          });
        },
      ),
    );
  }
}
