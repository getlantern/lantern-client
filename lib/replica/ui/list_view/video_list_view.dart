import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

/// ReplicaVideoListView renders a list of ReplicaVideoListItem.
/// Looks like this docs/replica_search_tabs.png
class ReplicaVideoListView extends ReplicaCommonListView {
  ReplicaVideoListView({
    Key? key,
    required ReplicaApi replicaApi,
    required String searchQuery,
  }) : super(
          key: key,
          replicaApi: replicaApi,
          searchQuery: searchQuery,
          searchCategory: SearchCategory.Video,
        );

  @override
  State<StatefulWidget> createState() => _ReplicaVideoListViewState();
}

class _ReplicaVideoListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    return renderPaginatedListView((context, item, index) {
      return ReplicaVideoListItem(
        key: Key(item.replicaLink.infohash),
        item: item,
        replicaApi: widget.replicaApi,
        onTap: () {
          context.pushRoute(
            ReplicaViewerLayout(
              replicaApi: widget.replicaApi,
              item: item,
              category: SearchCategory.Video,
            ),
          );
        },
      );
    });
  }
}
