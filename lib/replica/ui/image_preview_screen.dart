import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/common.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaImagePreviewScreen renders a Replica image in the middle of its view
class ReplicaImagePreviewScreen extends StatefulWidget {
  ReplicaImagePreviewScreen({Key? key, required this.replicaLink});
  final ReplicaLink replicaLink;

  @override
  State<ReplicaImagePreviewScreen> createState() =>
      _ReplicaImagePreviewScreenState();
}

class _ReplicaImagePreviewScreenState extends State<ReplicaImagePreviewScreen> {
  final ReplicaApi replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);

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
    return renderReplicaMediaScreen(
        context: context,
        api: replicaApi,
        link: widget.replicaLink,
        backgroundColor: white,
        category: SearchCategory.Image,
        body: Center(
            child: CachedNetworkImage(
                imageUrl: replicaApi.getThumbnailAddr(widget.replicaLink),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) {
                  // Just show an error thumbnail and a descriptive constant
                  // error text
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CAssetImage(
                          path: ImagePaths.spreadsheet,
                          size: 128,
                        ),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0)),
                        CText(
                          'No preview for this type of file'.i18n,
                          style: CTextStyle(fontSize: 16, lineHeight: 1.0),
                        ),
                      ]);
                })));
  }
}
