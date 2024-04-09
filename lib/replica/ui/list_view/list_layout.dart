import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';
import 'package:lantern/replica/ui/list_item/news_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

class ReplicaListLayout extends ReplicaCommonListView {
  const ReplicaListLayout({
    Key? key,
    required ReplicaApi replicaApi,
    required String searchQuery,
    required SearchCategory searchCategory,
  }) : super(
          key: key,
          replicaApi: replicaApi,
          searchQuery: searchQuery,
          searchCategory: searchCategory,
        );

  @override
  ReplicaCommonListViewState createState() => _ReplicaListLayoutState();
}

class _ReplicaListLayoutState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    var w = super.prebuild(context);
    if (w != null) {
      return w;
    }

    switch (widget.searchCategory) {
      case SearchCategory.Image:
        return PagedGridView<int, ReplicaSearchItem>(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          cacheExtent:
              super.getCommonCacheExtent(super.pagingController.value.itemList),
          scrollDirection: Axis.vertical,
          pagingController: super.pagingController,
          physics: defaultScrollPhysics,
          builderDelegate: PagedChildBuilderDelegate<ReplicaSearchItem>(
            animateTransitions: true,
            noItemsFoundIndicatorBuilder: (context) {
              return renderNoItemsFoundWidget();
            },
            itemBuilder: (context, item, index) {
              return ReplicaImageListItem(
                key: ValueKey(item.replicaLink.infohash),
                item: item,
                replicaApi: widget.replicaApi,
                onTap: () async {
                  await context.pushRoute(
                    ReplicaImageViewer(
                      replicaApi: widget.replicaApi,
                      category: SearchCategory.Image,
                      item: item,
                    ),
                  );
                },
              );
            },
          ),
        );
      case SearchCategory.Video:
        return renderPaginatedListView((context, item, index) {
          return ReplicaVideoListItem(
            key: Key(item.replicaLink.infohash),
            item: item,
            replicaApi: widget.replicaApi,
            onTap: () {
              context.pushRoute(
                ReplicaVideoViewer(
                  replicaApi: widget.replicaApi,
                  item: item,
                  category: SearchCategory.Video,
                ),
              );
            },
          );
        });
      case SearchCategory.Audio:
        return renderPaginatedListView(
          (context, item, index) => ReplicaAudioListItem(
            key: ValueKey(item.replicaLink.infohash),
            item: item,
            onTap: () {
              context.pushRoute(
                ReplicaAudioViewer(
                  replicaApi: widget.replicaApi,
                  item: item,
                  category: widget.searchCategory,
                ),
              );
            },
            replicaApi: widget.replicaApi,
          ),
        );
      case SearchCategory.Document:
        return renderPaginatedListView(
          (context, item, index) => ReplicaDocumentListItem(
            key: ValueKey(item.replicaLink.infohash),
            item: item,
            replicaApi: widget.replicaApi,
            onTap: () async {
              await context.pushRoute(
                ReplicaMiscViewer(
                  item: item,
                  category: SearchCategory.App,
                  replicaApi: widget.replicaApi,
                ),
              );
            },
          ),
        );
      case SearchCategory.App:
        return renderPaginatedListView(
          (context, item, index) => ReplicaAppListItem(
            key: ValueKey(item.replicaLink.infohash),
            item: item,
            replicaApi: widget.replicaApi,
            onTap: () async {
              await context.pushRoute(
                ReplicaMiscViewer(
                  item: item,
                  category: SearchCategory.App,
                  replicaApi: widget.replicaApi,
                ),
              );
            },
          ),
        );
      case SearchCategory.News:
        return renderPaginatedListView(
          (context, item, index) => ReplicaNewsListItem(
            key: ValueKey(item.replicaLink.infohash),
            item: item,
            replicaApi: widget.replicaApi,
            onTap: () async {
              if (item.serpLink != null) {
                await launchUrl(Uri.parse(item.serpLink as String));
              }
              return true;
            },
          ),
        );
      case SearchCategory.Unknown:
      default:
        return renderNoItemsFoundWidget();
    }
  }
}
