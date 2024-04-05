import 'package:cached_network_image/cached_network_image.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

// @echo
class ReplicaVideoListItem extends StatelessWidget {
  const ReplicaVideoListItem({
    required this.item,
    required this.onTap,
    required this.replicaApi,
    Key? key,
  }) : super(key: key);

  final ReplicaSearchItem item;
  final Function() onTap;
  final ReplicaApi replicaApi;

  // renderMetadata() fetches a thumbnail from Replica and renders it.
  // CachedNetworkVideo takes care of the caching for list items in a sensible way.
  // If there's no duration (i.e., request failed), don't render it.
  // If there's no thumbnail (i.e., request failed), render a black box
  Widget renderMetadata(BuildContext context) {
    // <08-22-22, kalli> Keeps throwing uncaught exceptions
    // See https://github.com/Baseflow/flutter_cached_network_image/issues/273 - really annoying!! 😠
    // Maybe try this: https://github.com/Baseflow/flutter_cached_network_image/issues/536#issuecomment-1216715184
    return CachedNetworkImage(
      cacheManager: CustomCacheManager.instance,
      maxHeightDiskCache: 150,
      maxWidthDiskCache: (MediaQuery.of(context).size.width * .5).toInt(),
      imageBuilder: (context, imageProvider) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .45,
                  height: 100,
                  child: Image(
                    image: imageProvider,
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: 4,
                child: renderDurationTextbox(),
              ),
              PlayButton(custom: true),
            ],
          ),
        );
      },
      imageUrl: replicaApi.getThumbnailAddr(item.replicaLink),
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(
            top: 8,
            bottom: 8,
          ), // padding to match loaded thumbnail item
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * .45,
              height: 100,
              child: Container(
                color: grey4,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        // XXX <02-12-2021> soltzen: if an error occurs, show a black box.
        // This is common in Replica since we just recently deployed a
        // metadata materialization service
        // (https://github.com/getlantern/replica-infrastructure/pull/30) and
        // metadata is not fully available.
        return Padding(
          padding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .45,
                  height: 100,
                  child: Container(color: grey4),
                ),
              ),
              Positioned(
                left: 8,
                bottom: 4,
                child: renderDurationTextbox(),
              ),
              PlayButton(custom: true),
            ],
          ),
        );
      },
    );
  }

  Widget renderDurationTextbox() {
    return ValueListenableBuilder(
      valueListenable: replicaApi.getDuration(item.replicaLink),
      builder: (
        BuildContext context,
        CachedValue<double?> cached,
        Widget? child,
      ) {
        if (cached.value == null) {
          return Container();
        }
        return InfoTextBox(
          text: cached.value!.toMinutesAndSeconds(),
        );
      },
    );
  }

  // XXX <30-11-2021> soltzen: Fetching metadata for this list item goes like this:
  // - The video duration is fetched in initState(): if it works, setState is
  //   called for a rebuild
  // - The thumbnail is fetched with CachedNetworkVideo in build():
  //   - During the fetch, a progress indicator is shown
  //   - After a successful fetch, the thumbnail is rendered
  //   - After a failed fetch, a black box is rendered
  @override
  Widget build(BuildContext context) {
    return ListItemFactory.replicaItem(
      link: item.replicaLink,
      api: replicaApi,
      onTap: onTap,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          renderMetadata(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CText(
                    removeExtension(item.fileNameTitle),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: tsBody1Short.copiedWith(color: blue4),
                  ),
                  const SizedBox(height: 10),
                  CText(
                    item.metaDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tsBody2Short,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
