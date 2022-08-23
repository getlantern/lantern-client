import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

class ReplicaListLayout extends ReplicaCommonListView {
  ReplicaListLayout({
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
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 10.0,
          ),
          cacheExtent:
              super.getCommonCacheExtent(super.pagingController.value.itemList),
          scrollDirection: Axis.vertical,
          pagingController: super.pagingController,
          builderDelegate: PagedChildBuilderDelegate<ReplicaSearchItem>(
            animateTransitions: true,
            noItemsFoundIndicatorBuilder: (context) {
              return renderNoItemsFoundWidget();
            },
            itemBuilder: (context, item, index) {
              return ReplicaImageListItem(
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
      case SearchCategory.Unknown:
      default:
        return Container();
    }
  }
}
