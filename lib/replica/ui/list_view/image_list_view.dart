import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/vpn/vpn.dart';
import 'package:lantern/replica/common.dart';

/// ReplicaImageListView renders a list of ReplicaImageListItem.
/// Looks like this docs/replica_image_listview.png
class ReplicaImageListView extends ReplicaCommonListView {
  ReplicaImageListView({
    Key? key,
    required ReplicaApi replicaApi,
    required String searchQuery,
  }) : super(
          key: key,
          replicaApi: replicaApi,
          searchQuery: searchQuery,
          searchCategory: SearchCategory.Image,
        );

  @override
  State<StatefulWidget> createState() => _ReplicaImageListViewState();
}

class _ReplicaImageListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    var w = super.prebuild(context);
    if (w != null) {
      return w;
    }
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
                ReplicaViewerLayout(
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
  }
}
