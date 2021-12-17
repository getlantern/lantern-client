import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/models/replica_link.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// LinkOpenerScreen is a 'loading' screen for Replica links that:
/// - Checks if Replica is available by re-running ReplicaCommon.init()
///   - This may not be initialized if we came from a deeplink
/// - Determine the content type of this Replica link (e.g., video, PDF, etc.)
/// - Show a spinner until we figure out the content type
/// - If we failed to do so (because of a timeout, Replica is not initialized,
///   etc.), show an error and don't proceed; the user is expected to press the
///   back button.
///
/// Looks like this docs/replica_link_opener.png
///
/// XXX <04-12-21> soltzen: this is the only location we need to check if
/// Replica is initialized, since we might've come from a deeplink.
/// In all other widgets, we 100% know the status of Replica since the Replica
/// tab will not be visible if Replica is not initialized.
/// In other words, we will never reach any Replica screen (other than this) if
/// Replica is not initialized.
class ReplicaLinkOpenerScreen extends StatefulWidget {
  ReplicaLinkOpenerScreen({Key? key, required this.replicaLink})
      : super(key: key);
  final ReplicaLink replicaLink;

  @override
  State<StatefulWidget> createState() => _LinkOpenerScreen();
}

class _LinkOpenerScreen extends State<ReplicaLinkOpenerScreen> {
  bool _didFailToInitReplica = false;
  final ReplicaApi _replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);

  @override
  void initState() {
    ReplicaCommon.init().then((_) {
      if (!ReplicaCommon.isReplicaRunning()) {
        if (mounted) {
          setState(() {
            logger.e(
                'initState(): ReplicaCommon.init() failed. We will not continue');
            _didFailToInitReplica = true;
          });
        }
        return;
      }

      _replicaApi.fetchCategoryFromReplicaLink(widget.replicaLink).then((cat) {
        logger.v('category is ${cat.toString()}');
        switch (cat) {
          case SearchCategory.Video:
            return context.replaceRoute(
                ReplicaVideoPlayerScreen(replicaLink: widget.replicaLink));
          case SearchCategory.Image:
            return context.replaceRoute(
                ReplicaImagePreviewScreen(replicaLink: widget.replicaLink));
          case SearchCategory.Audio:
            return context.replaceRoute(
                ReplicaAudioPlayerScreen(replicaLink: widget.replicaLink));
          case SearchCategory.Document:
          case SearchCategory.App:
          case SearchCategory.Unknown:
            return context.replaceRoute(ReplicaUnknownItemScreen(
                category: cat, replicaLink: widget.replicaLink));
        }
      });
    });
    super.initState();
  }

  Widget renderBody() {
    if (_didFailToInitReplica) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Flexible(
                child: Text(
              'failed_to_init_replica'.i18n,
            ))
          ]);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 16),
          child: Text('awaiting_result'.i18n),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('replica_link_fetcher'.i18n),
          backgroundColor: Colors.blue,
        ),
        body: Center(child: renderBody()));
  }
}
