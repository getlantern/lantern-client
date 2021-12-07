import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/logic/replica_link.dart';
import 'package:lantern/replica/models/video_item.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaVideoListTile extends StatefulWidget {
  const ReplicaVideoListTile({
    required this.videoItem,
    required this.onTap,
    required this.onDownloadBtnPressed,
    required this.onShareBtnPressed,
    required this.replicaApi,
  });

  final ReplicaVideoItem videoItem;
  final Function(ReplicaLink) onTap;
  final Function() onDownloadBtnPressed;
  final Function() onShareBtnPressed;
  final ReplicaApi replicaApi;

  @override
  State<StatefulWidget> createState() => _ReplicaVideoListTileState();
}

// XXX <30-11-2021> soltzen: Fetching metadata for this list item goes like this:
// - The video duration is fetched in initState(): if it works, setState is
//   called for a rebuild
// - The thumbnail is fetched with CachedNetworkImage in build():
//   - During the fetch, a progress indicator is shown
//   - After a successful fetch, the thumbnail is rendered
//   - After a failed fetch, a black box is rendered
class _ReplicaVideoListTileState extends State<ReplicaVideoListTile> {
  // renderMetadata() fetches a thumbnail from Replica and renders it.
  // CachedNetworkImage takes care of the caching for list items in a sensible way.
  // If there's no duration (i.e., request failed), don't render it.
  // If there's no thumbnail (i.e., request failed), render a black box
  Widget renderMetadata() {
    final renderDuration = () {
      return FutureBuilder(
        future: widget.replicaApi.fetchDuration(widget.videoItem.replicaLink!),
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }
          return Positioned(
              bottom: 5,
              right: 5,
              child: Text(
                snapshot.data!.toStringAsFixed(2),
                style: const TextStyle(
                  backgroundColor: Colors.black,
                  fontSize: 10.0,
                  color: Colors.white,
                ),
              ));
        },
      );
    };

    return CachedNetworkImage(
        imageBuilder: (context, imageProvider) {
          return Stack(
            children: [
              Image(image: imageProvider),
              renderDuration(),
            ],
          );
        },
        imageUrl:
            widget.replicaApi.getThumbnailAddr(widget.videoItem.replicaLink!),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) {
          // XXX <02-12-2021> soltzen: if an error occurs, show a black box.
          // This is common in Replica since we just recently deployed a
          // metadata materialization service
          // (https://github.com/getlantern/replica-infrastructure/pull/30) and
          // metadata is not fully available.
          return Stack(
            children: [
              Container(color: Colors.black),
              renderDuration(),
            ],
          );
        });
  }

  Widget renderVideoItem() {
    return InkWell(
        onTap: () => widget.onTap(widget.videoItem.replicaLink!),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  renderMetadata(),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
                  Text(
                    widget.videoItem.displayName,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
                ],
              ),
            )));
  }

  Widget renderVideoMenu() {
    return Positioned(
        bottom: 0,
        right: 0,
        child: PopupMenuButton(
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'download',
              child: const Text('Download'),
              onTap: () => widget.onDownloadBtnPressed(),
            ),
            PopupMenuItem<String>(
              value: 'share',
              child: const Text('Share'),
              onTap: () => widget.onShareBtnPressed(),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO Since the images **always** take 2-3 seconds to load, maybe just
    // **don't** render the list immediately, but fetch the metadata first and
    // then show them after a 2-3 seconds delay, just like YouTube does it.
    return Card(
        child: Stack(children: [
      renderVideoItem(),
      renderVideoMenu(),
    ]));
  }
}
