import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/ui/viewers/layout.dart';
import 'package:path_provider/path_provider.dart';

/// Multi-purpose class which renders a Replica viewer for
/// 1. Documents
/// 2. Apps
/// 3. Unknown
/// It does not offer a full screen option unless we have a PDF
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
  String? tempFile;
  Future<void>? fetched;
  late bool isPDF = false;

  @override
  void initState() {
    super.initState();
    isPDF = widget.item.primaryMimeType == 'application/pdf';
    if (isPDF) {
      // Fetch to PDF to an application-specific temp file so that we can open it
      // in a PDFView.
      getTemporaryDirectory().then((tempDir) {
        setState(() {
          tempFile =
              '${tempDir.absolute.path}/${widget.item.replicaLink.infohash}';
          fetched = widget.replicaApi.fetch(widget.item.replicaLink, tempFile!);
        });
      });
    }
  }

  @override
  void dispose() {
    // Delete the temp PDF file when we're done viewing it.
    if (isPDF && tempFile != null) {
      File(tempFile!).deleteSync();
    }
    super.dispose();
  }

  @override
  bool ready() => fetched != null || !isPDF;

  @override
  Widget body(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      fit: StackFit.loose,
      children: [
        Container(
          height: 150,
          width: 150,
          child: GestureDetector(
            child: renderMimeIcon(widget.item.fileNameTitle, 2.0),
            onTap: () async {
              if (isPDF && tempFile != null) {
                await context.router.push(
                  FullScreenDialogPage(
                    widget: PDFScreen(
                      path: tempFile!,
                      item: widget.item,
                      replicaApi: widget.replicaApi,
                    ),
                  ),
                );
              }
              ;
            },
          ),
        ),
        if (isPDF)
          Transform.translate(
            offset: const Offset(0, -10),
            child: InfoTextBox(
              text: 'read_details'.i18n.toUpperCase(),
              invertColors: true,
            ),
          ),
      ],
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String path;
  final ReplicaSearchItem item;
  final ReplicaApi replicaApi;

  PDFScreen({
    Key? key,
    required this.path,
    required this.item,
    required this.replicaApi,
  }) : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: widget.item.fileNameTitle,
      actionButton: (errorMessage.isEmpty)
          ? FutureBuilder<PDFViewController>(
              future: _controller.future,
              builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                if (snapshot.hasData) {
                  return InfoTextBox(
                    text: '${currentPage! + 1} / ${pages! + 1}',
                  );
                }
                return Container();
              },
            )
          : Container(),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            // swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            fitEachPage: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
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
          errorMessage.isEmpty
              ? !isReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : renderErrorViewingFile(
                  context,
                  widget.item,
                  widget.replicaApi,
                ),
        ],
      ),
    );
  }
}
