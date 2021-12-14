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

/// ReplicaUnknownItemScreen is the default preview screen for replica items
/// that we couldn't figure out their category.
///
/// Looks like this: docs/replica_unknown_item.png
///
/// TODO <13-12-2021> soltzen: if you open
/// replica://AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA, it will **also** open
/// this screen: this happens since the error could've occurred because of a
/// timeout, not a faulty link. This should be fixed to address faulty links as
/// opposed to timeouts
class ReplicaUnknownItemScreen extends StatefulWidget {
  ReplicaUnknownItemScreen(
      {Key? key,
      required this.replicaLink,
      required this.category,
      this.mimeType});
  final ReplicaLink replicaLink;
  final SearchCategory category;
  final String? mimeType;

  @override
  State<ReplicaUnknownItemScreen> createState() =>
      _ReplicaUnknownItemScreenState();
}

class _ReplicaUnknownItemScreenState extends State<ReplicaUnknownItemScreen> {
  final ReplicaApi replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);

  @override
  Widget build(BuildContext context) {
    return renderReplicaMediaScreen(
        context: context,
        api: replicaApi,
        link: widget.replicaLink,
        backgroundColor: white,
        category: widget.category,
        mimeType: widget.mimeType,
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
                  style: tsBody1,
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                TextButton(
                  onPressed: () async {
                    await replicaApi.download(widget.replicaLink);
                  },
                  child: CText(
                    'Download',
                    style: tsButton.copiedWith(color: indicatorRed),
                  ),
                ),
              ]),
        )));
  }
}
