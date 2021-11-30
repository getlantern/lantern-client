import 'package:auto_route/src/router/auto_router_x.dart';
import 'package:flutter/material.dart';
import 'package:lantern/core/router/router.gr.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/common.dart';
import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/replica/ui/searchcategory.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// LinkOpenerScreen is a 'loading' screen for Replica links that:
/// - Checks if Replica is available by re-running ReplicaCommon.init()
///   - This may not be initialized if we came from a deeplink
/// - Determine what's the content type of this Replica link (e.g., video, PDF, etc.)
/// - Show a spinner until we figure out the content type
/// - If we failed to do so (because of a timeout, Replica is not initialized,
///   etc.), show an error and don't proceed; the user is expected to press the
///   back button.
///
/// XXX <04-12-21> soltzen: this is the only location we need to check if
/// Replica is initialized, since we might've come from a deeplink.
/// In all other widgets, we 100% know the status of Replica since the Replica
/// tab will not be visible if Replica is not initialized.
/// In other words, we will never reach any Replica screen (other than this) if
/// Replica is not initialized.
class LinkOpenerScreen extends StatefulWidget {
  LinkOpenerScreen({Key? key, required this.replicaLink}) : super(key: key);
  final ReplicaLink replicaLink;

  @override
  State<StatefulWidget> createState() => _LinkOpenerScreen();
}

class _LinkOpenerScreen extends State<LinkOpenerScreen> {
  bool _didFailToInitReplica = false;
  final ReplicaApi _replicaApi =
      ReplicaApi(ReplicaCommon.getReplicaServerAddr()!);

  @override
  void initState() {
    ReplicaCommon.init().then((_) {
      logger.v('XXX initState(): ReplicaCommon.init() ran');
      if (!ReplicaCommon.isReplicaRunning()) {
        if (mounted) {
          setState(() {
            logger.v('XXX initState(): ReplicaCommon.init() failed');
            _didFailToInitReplica = true;
          });
        }
        return;
      }

      logger.v('XXX initState(): ReplicaCommon.init() OK');
      _replicaApi.fetchCategoryFromReplicaLink(widget.replicaLink).then((cat) {
        logger.v('XXX initState: category is ${cat.toString()}');
        switch (cat) {
          case SearchCategory.Video:
            logger.v('XXX initState: launching video view');
            return context.replaceRoute(
                ReplicaVideoPlayerScreen(replicaLink: widget.replicaLink));
          case SearchCategory.Web:
          case SearchCategory.Image:
          case SearchCategory.Audio:
          case SearchCategory.Document:
          case SearchCategory.App:
          case SearchCategory.Unknown:
            logger.v('XXX initState: launching unknown item view');
            return context.replaceRoute(UnknownItemScreen(
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
            const Flexible(
                child: Text(
              'Error: Failed to initialize Replica',
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
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Awaiting result...'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Replica Link Fetcher'),
          backgroundColor: Colors.blue,
        ),
        body: Center(child: renderBody()));
  }
}
