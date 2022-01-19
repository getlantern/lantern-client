import 'package:lantern/common/common.dart';
import 'package:lantern/replica/logic/api.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/listitems/video_listitem.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

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
            ReplicaVideoPlayerScreen(
              replicaApi: widget.replicaApi,
              replicaLink: item.replicaLink,
              mimeType: item.primaryMimeType,
            ),
          );
        },
      );
    });
  }
}
