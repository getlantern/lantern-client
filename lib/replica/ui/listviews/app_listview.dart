import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/listitems/app_listitem.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaAppListView renders 'App' Replica items
/// Looks quite similar to ReplicaDocumentListView: docs/replica_app_listview.png
class ReplicaAppListView extends ReplicaCommonListView {
  ReplicaAppListView({Key? key, required String searchQuery})
      : super(
            key: key,
            searchQuery: searchQuery,
            searchCategory: SearchCategory.App);
  @override
  State<StatefulWidget> createState() => _ReplicaAppListViewState();
}

class _ReplicaAppListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    return renderPaginatedListView((context, item, index) {
      return ReplicaAppListItem(
        item: item,
        replicaApi: replicaApi,
        onTap: () async {
          await context.pushRoute(ReplicaUnknownItemScreen(
              replicaLink: item.replicaLink, category: SearchCategory.App));
        },
      );
    });
  }
}
