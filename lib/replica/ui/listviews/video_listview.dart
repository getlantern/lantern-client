import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/models/search_item.dart';
import 'package:lantern/replica/ui/listviews/common_listview.dart';
import 'package:lantern/replica/models/searchcategory.dart';
import 'package:lantern/replica/ui/listitems/video_listitem.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

/// ReplicaVideoListView renders a list of ReplicaVideoListItem.
/// Looks like this docs/replica_search_tabs.png
class ReplicaVideoListView extends ReplicaCommonListView {
  ReplicaVideoListView({Key? key, required String searchQuery})
      : super(
            key: key,
            searchQuery: searchQuery,
            searchCategory: SearchCategory.Video);
  @override
  State<StatefulWidget> createState() => _ReplicaVideoListViewState();
}

class _ReplicaVideoListViewState extends ReplicaCommonListViewState {
  @override
  Widget build(BuildContext context) {
    var w = super.prebuild(context);
    if (w != null) {
      return w;
    }
    return PagedListView<int, ReplicaSearchItem>.separated(
      cacheExtent:
          super.getCommonCacheExtent(super.pagingController.value.itemList),
      scrollDirection: Axis.vertical,
      pagingController: super.pagingController,
      builderDelegate: PagedChildBuilderDelegate<ReplicaSearchItem>(
        animateTransitions: true,
        noItemsFoundIndicatorBuilder: (context) {
          return Column(
            children: [
              const CAssetImage(
                path: ImagePaths.unknown,
                size: 168,
              ),
              CText(
                'Sorry, we couldn’t find anything matching that search'.i18n,
                style: tsBody1,
              ),
            ],
          );
        },
        itemBuilder: (context, item, index) {
          return ReplicaVideoListItem(
              item: item,
              replicaApi: super.replicaApi,
              onTap: () {
                context.pushRoute(ReplicaVideoPlayerScreen(
                    replicaLink: item.replicaLink,
                    mimeType: item.primaryMimeType));
              });
        },
      ),
      separatorBuilder: (context, index) => const SizedBox.shrink(),
    );
  }
}
