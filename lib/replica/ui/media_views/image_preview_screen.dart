import 'package:cached_network_image/cached_network_image.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/replica_model.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/common.dart';

/// ReplicaImagePreviewScreen renders a Replica image in the middle of its view
///
/// This screen supports landscape and portrait orientations
class ReplicaImagePreviewScreen extends StatefulWidget {
  ReplicaImagePreviewScreen({Key? key, required this.replicaLink});

  final ReplicaLink replicaLink;

  @override
  State<ReplicaImagePreviewScreen> createState() =>
      _ReplicaImagePreviewScreenState();
}

class _ReplicaImagePreviewScreenState extends State<ReplicaImagePreviewScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return replicaModel.withReplicaApi((context, replicaApi, child) {
      // TODO: use CImageViewer
      return renderReplicaMediaViewScreen(
        context: context,
        api: replicaApi,
        link: widget.replicaLink,
        backgroundColor: white,
        category: SearchCategory.Image,
        body: Center(
          child: CachedNetworkImage(
            imageUrl: replicaApi.getDownloadAddr(widget.replicaLink),
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) {
              // Just show an error thumbnail and a descriptive constant
              // error text
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CAssetImage(
                    path: SearchCategory.Image.getRelevantImagePath(),
                    size: 128,
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
                  CText(
                    'no_preview_for_this_type_of_file'.i18n,
                    style: tsBody1,
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
