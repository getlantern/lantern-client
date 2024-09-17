import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

// TODO <08-11-2022> kalli: This isn't used right now?

/// ReplicaLinkHandler is a 'loading' screen for Replica links that:
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
@RoutePage(name: 'ReplicaLinkHandler')
class ReplicaLinkHandler extends StatefulWidget {
  ReplicaLinkHandler({
    Key? key,
    required this.replicaApi,
    required this.replicaLink,
  }) : super(key: key);
  final ReplicaApi replicaApi;
  final ReplicaLink replicaLink;

  @override
  State<StatefulWidget> createState() => _LinkOpenerScreen();
}

class _LinkOpenerScreen extends State<ReplicaLinkHandler> {
  @override
  void initState() {
    widget.replicaApi
        .fetchCategoryFromReplicaLink(widget.replicaLink)
        .then((cat) {
      logger.v('category is ${cat.toString()}');
      switch (cat) {
        case SearchCategory.Video:
        // TODO <08-17-22, kalli> This should navigate to ReplicaVideoViewer
        // return context.replaceRoute(
        //   FullscreenReplicaVideoViewer(
        //     replicaApi: widget.replicaApi,
        //     replicaLink: widget.replicaLink,
        //   ),
        // );
        case SearchCategory.Image:
        // TODO <08-11-2022> kalli: this should navigate to ReplicaImageViewer
        // return context.replaceRoute(
        //   FullscreenReplicaImageViewer(replicaLink: widget.replicaLink),
        // );
        case SearchCategory.Audio:
        // TODO <08-11-2022> kalli: this should navigate to ReplicaAudioViewer
        // return context.replaceRoute(
        //   ReplicaAudioPlayerScreen(
        //     replicaApi: widget.replicaApi,
        //     replicaLink: widget.replicaLink,
        //   ),
        // );
        case SearchCategory.Document:
        case SearchCategory.App:
        case SearchCategory.Unknown:
        default:
          // TODO <08-11-2022> kalli: this should navigate to ReplicaMiscViewer
          // return context.replaceRoute(
          //   ReplicaUnknownItemScreen(
          //     category: cat,
          //     replicaLink: widget.replicaLink,
          //   ),
          // );
          return Container();

      }
    });

    super.initState();
  }

  Widget renderBody() {
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
    return BaseScreen(
      showAppBar: true,
      title: 'replica_link_fetcher'.i18n,
      body: Center(child: renderBody()),
    );
  }
}
