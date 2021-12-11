import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/listitems/common_listitem.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class ReplicaVideoListItem extends ReplicaCommonListItem {
  ReplicaVideoListItem({
    required this.item,
    required Function() onDownloadBtnPressed,
    required Function() onShareBtnPressed,
    required Function() onTap,
    required this.replicaApi,
  }) : super(
          onDownloadBtnPressed: onDownloadBtnPressed,
          onShareBtnPressed: onShareBtnPressed,
          onTap: onTap,
        );
  final ReplicaSearchItem item;
  final ReplicaApi replicaApi;

  @override
  State<StatefulWidget> createState() =>
      _ReplicaVideoListItemState(replicaApi, item);
}

// XXX <30-11-2021> soltzen: Fetching metadata for this list item goes like this:
// - The video duration is fetched in initState(): if it works, setState is
//   called for a rebuild
// - The thumbnail is fetched with CachedNetworkVideo in build():
//   - During the fetch, a progress indicator is shown
//   - After a successful fetch, the thumbnail is rendered
//   - After a failed fetch, a black box is rendered
class _ReplicaVideoListItemState extends ReplicaCommonListItemState {
  _ReplicaVideoListItemState(this.replicaApi, this.item);
  final ReplicaSearchItem item;
  late Future<double?> _fetchDurationFuture;
  final ReplicaApi replicaApi;

  @override
  void initState() {
    _fetchDurationFuture = replicaApi.fetchDuration(item.replicaLink);
    super.initState();
  }

  // renderMetadata() fetches a thumbnail from Replica and renders it.
  // CachedNetworkVideo takes care of the caching for list items in a sensible way.
  // If there's no duration (i.e., request failed), don't render it.
  // If there's no thumbnail (i.e., request failed), render a black box
  Widget renderMetadata() {
    return CachedNetworkImage(
        imageBuilder: (context, imageProvider) {
          return SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image(
                      image: imageProvider, filterQuality: FilterQuality.high),
                ),
                renderDurationTextbox(),
                const Center(
                    child: CAssetImage(path: ImagePaths.play_circle_filled)),
              ],
            ),
          );
        },
        imageUrl: replicaApi.getThumbnailAddr(item.replicaLink),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(color: Colors.black),
              ),
              renderDurationTextbox(),
              const Center(
                  child: CAssetImage(path: ImagePaths.play_circle_filled)),
            ],
          );
        });
  }

  Widget renderDurationTextbox() {
    return FutureBuilder(
      future: _fetchDurationFuture,
      builder: (BuildContext context, AsyncSnapshot<double?> snapshot) {
        // if we got an error,
        // or, didn't receive data,
        // or, got null data,
        // display render nothing
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        return Positioned(
            bottom: 15,
            left: 5,
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
  }

  @override
  Widget build(BuildContext context) {
    return boilerplate(Stack(children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: SizedBox(
            height: 90,
            child: Row(
              children: <Widget>[
                renderMetadata(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(8.0),
                    child: CText(
                      item.displayName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: CTextStyle(
                        fontWeight: FontWeight.w500,
                        lineHeight: 16,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    ]));
  }
}
