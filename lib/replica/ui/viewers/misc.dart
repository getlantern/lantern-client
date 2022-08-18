import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/ui/viewers/layout.dart';
import 'package:path_provider/path_provider.dart';

/// Multi-purpose class which renders a Replica viewer for
/// 1. Documents
/// 2. Apps
/// 3. Unknown
/// It does not offer a full screen option (since we don't preview these files)
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

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    // Delete the temp file when we're done viewing it.
    if (tempFile != null) {
      File(tempFile!).deleteSync();
    }
    super.dispose();
  }

  @override
  bool ready() => fetched != null;

  @override
  Widget body(BuildContext context) {
    final isPDF = widget.item.primaryMimeType == 'application/pdf';
    switch (widget.category) {
      case SearchCategory.Document:
        return GestureDetector(
          child: renderIconPlaceholder(widget.item.primaryMimeType.toString()),
          onTap: () async {
            if (isPDF) {
              await context.router.push(
                FullScreenDialogPage(
                  // TODO <08-17-22, kalli> Implement landscape, corrupt PDF etc - https://pub.dev/packages/flutter_pdfview/example
                  widget: PDFView(
                    filePath: tempFile,
                    enableSwipe: true,
                    pageFling: true,
                    pageSnap: true,
                    fitPolicy: FitPolicy.BOTH,
                    preventLinkNavigation: false,
                  ),
                ),
              );
            }
            ;
          },
        );
      case SearchCategory.App:
        return renderIconPlaceholder(widget.item.primaryMimeType.toString());
      case SearchCategory.Unknown:
      default:
        return renderIconPlaceholder(widget.item.primaryMimeType.toString());
    }
  }

  Widget renderIconPlaceholder(String primaryMimeType) {
    return Flexible(
      child: renderMimeIcon(primaryMimeType),
    );
  }
}
