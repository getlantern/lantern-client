import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

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
// TODO <08-08-22, kalli> Pending design confirmation, sounds like we should chat with soltzen about this too
class ReplicaUnknownItemScreen extends StatefulWidget {
  ReplicaUnknownItemScreen({
    Key? key,
    required this.replicaLink,
    required this.category,
    this.mimeType,
  });

  final ReplicaLink replicaLink;
  final SearchCategory category;
  final String? mimeType;

  @override
  State<ReplicaUnknownItemScreen> createState() =>
      _ReplicaUnknownItemScreenState();
}

class _ReplicaUnknownItemScreenState extends State<ReplicaUnknownItemScreen> {
  @override
  Widget build(BuildContext context) {
    return replicaModel.withReplicaApi(
      (context, replicaApi, child) {
        return Text('Unknown - TBD');
        // return ReplicaViewerLayout(
        //   context: context,
        //   api: replicaApi,
        //   link: widget.replicaLink,
        //   backgroundColor: white,
        //   category: widget.category,
        //   mimeType: widget.mimeType,
        //   body: Center(
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [
        //           CAssetImage(
        //             path: widget.category.getRelevantImagePath(),
        //             size: 128,
        //           ),
        //           const Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
        //           CText(
        //             'no_preview_for_this_type_of_file'.i18n,
        //             style: tsBody1,
        //           ),
        //           const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
        //           TextButton(
        //             onPressed: () async {
        //               await replicaApi.download(widget.replicaLink);
        //               // TODO <08-08-22, kalli> Confirm we can use BotToast
        //               BotToast.showText(text: 'download_started'.i18n);
        //             },
        //             child: CText(
        //               'download'.i18n,
        //               style: tsButton.copiedWith(color: indicatorRed),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // );
      },
    );
  }
}
