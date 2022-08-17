import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

/// ReplicaAppListView renders 'App' Replica items
/// Looks quite similar to ReplicaDocumentListView: docs/replica_app_listview.png
class ReplicaAppListView extends ReplicaCommonListView {
  ReplicaAppListView({
    Key? key,
    required ReplicaApi replicaApi,
    required String searchQuery,
  }) : super(
          key: key,
          replicaApi: replicaApi,
          searchQuery: searchQuery,
          searchCategory: SearchCategory.App,
        );

  @override
  State<StatefulWidget> createState() => _ReplicaAppListViewState();
}

class _ReplicaAppListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    return renderPaginatedListView((context, item, index) {
      return ReplicaAppListItem(
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
      );
    });
  }
}
