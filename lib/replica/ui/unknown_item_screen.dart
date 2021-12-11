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

class UnknownItemScreen extends StatefulWidget {
  UnknownItemScreen(
      {Key? key,
      required this.replicaLink,
      required this.category,
      this.mimeType});
  final ReplicaLink replicaLink;
  final SearchCategory category;
  final String? mimeType;

  @override
  State<UnknownItemScreen> createState() => _UnknownItemScreenState();
}

class _UnknownItemScreenState extends State<UnknownItemScreen> {
  final ReplicaApi replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);

  @override
  void initState() {
    replicaApi.bindDownloaderBackgroundIsolate(() {
      if (mounted) {
        showErrorDialog(context,
            des: 'Download request failed. Please try again');
      }
    }, () {
      if (mounted) {
        showSnackbar(
            context: context, content: const Text('Download enqueued'));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    replicaApi.unbindDownloadManagerIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: renderAppBar(context, replicaApi, widget.replicaLink,
            widget.category, widget.mimeType),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CAssetImage(
                  path: ImagePaths.spreadsheet,
                  size: 128,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
                CText(
                  'No preview for this type of file',
                  style: CTextStyle(fontSize: 12, lineHeight: 1.0),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                TextButton(
                  onPressed: () async {
                    await replicaApi.download(widget.replicaLink);
                  },
                  child: CText(
                    'Download',
                    style: CTextStyle(
                        fontSize: 12, lineHeight: 1.0, color: indicatorRed),
                  ),
                ),
              ]),
        )));
  }
}
